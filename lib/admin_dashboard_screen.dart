import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final List<String> _filterOptions = ['Diario', 'Semanal', 'Mensual'];

  @override
  void initState() {
    super.initState();
    // Carga inicial de datos al entrar al panel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().updateStats('Diario');
    });
  }

  // 🔥 Función corregida para cerrar sesión y redirigir a la raíz '/'
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Cerrar Sesión",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "¿Estás seguro de que quieres salir del panel de administración?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              context.read<AuthProvider>().logout(); // Limpia token y sesión

              // 🔥 CORRECCIÓN: Según tu main.dart, el path del Login es '/'
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Salir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 📅 Selector de rango de fechas personalizado
  Future<void> _selectCustomRange(BuildContext context) async {
    final adminProv = context.read<AdminProvider>();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: 'SELECCIONA RANGO DE VENTAS',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String start = DateFormat('yyyy-MM-dd').format(picked.start);
      String end = DateFormat('yyyy-MM-dd').format(picked.end);
      adminProv.updateStatsCustom(start, end);
    }
  }

  Color _getThemeColor(String filter) {
    if (filter == 'Diario') return Colors.blue;
    if (filter == 'Semanal') return Colors.purple;
    if (filter == 'Mensual') return Colors.orange;
    return Colors.teal;
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Icono de Logout que abre el diálogo de confirmación
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          onPressed: () => _showLogoutDialog(context),
        ),
        title: const Text(
          "Panel Administrativo",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.black),
            onPressed: () => _selectCustomRange(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Resumen de Ventas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (adminProvider.currentFilter == 'Personalizado')
                  Text(
                    "${adminProvider.startDate} / ${adminProvider.endDate}",
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),

            // Chips de filtro rápido
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  bool isSelected = adminProvider.currentFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.black,
                      backgroundColor: Colors.white,
                      onSelected: (selected) {
                        if (selected) {
                          adminProvider.updateStats(filter);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 30),

            // Indicador de carga o Tarjetas de datos
            adminProvider.isLoading
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                  )
                : Row(
                    children: [
                      _buildStatCard(
                        "Ingresos Totales",
                        "S/ ${adminProvider.totalVentas.toStringAsFixed(2)}",
                        Icons.monetization_on,
                        _getThemeColor(adminProvider.currentFilter),
                      ),
                      const SizedBox(width: 15),
                      _buildStatCard(
                        "Pedidos Atendidos",
                        adminProvider.totalPedidos.toString(),
                        Icons.shopping_bag,
                        Colors.green,
                      ),
                    ],
                  ),

            const SizedBox(height: 40),

            const Text(
              "Gestión Rápida",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: ListView(
                children: [
                  _buildMenuOption(
                    context,
                    "Ofertas y Promociones",
                    "Activa o desactiva descuentos",
                    Icons.local_offer,
                    Colors.redAccent,
                    () => context.push('/admin-offers'),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
