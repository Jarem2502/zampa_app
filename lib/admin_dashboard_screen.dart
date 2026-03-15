import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';

const Color zampaRed = Color(0xFFDB0212);
const Color zampaYellow = Color(0xFFF5D509);
const Color zampaGreen = Color(0xFF32903A);
const Color zampaWhite = Color(0xFFD1D1D1);
const Color zampaBlack = Color(0xFF010201);

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedPeriodIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().updateStats('Diario');
    });
  }

  // 🔥 NUEVO: Diálogo de confirmación antes de cerrar sesión
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: zampaRed),
            SizedBox(width: 10),
            Text(
              "Cerrar Sesión",
              style: TextStyle(fontWeight: FontWeight.w900, color: zampaBlack),
            ),
          ],
        ),
        content: const Text(
          "¿Estás seguro de que deseas salir del panel de control?",
          style: TextStyle(color: Colors.black54, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Cerramos el cuadro
              await context
                  .read<AuthProvider>()
                  .logout(); // Cerramos sesión real
              if (mounted) context.go('/'); // Navegamos al inicio
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: zampaRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Salir",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      helpText: 'SELECCIONA UN RANGO DE FECHAS', // Texto de ayuda arriba
      cancelText: 'CANCELAR',
      confirmText: 'FILTRAR',
      saveText: 'FILTRAR',
      builder: (context, child) {
        // 🔥 CORRECCIÓN: Forzamos el fondo a blanco y arreglamos los colores para que no se vea negro
        return Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: Colors.white, // Fondo general blanco
            colorScheme: const ColorScheme.light(
              primary:
                  zampaGreen, // Color del botón de guardar y fechas seleccionadas
              onPrimary: Colors.white, // Texto sobre el verde
              surface:
                  Colors.white, // Fondo de la barra superior del calendario
              onSurface: zampaBlack, // Letras de los días del mes en negro
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: zampaBlack),
              titleTextStyle: TextStyle(
                color: zampaBlack,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _selectedPeriodIndex = -1);

      String start =
          "${picked.start.year}-${picked.start.month.toString().padLeft(2, '0')}-${picked.start.day.toString().padLeft(2, '0')}";
      String end =
          "${picked.end.year}-${picked.end.month.toString().padLeft(2, '0')}-${picked.end.day.toString().padLeft(2, '0')}";

      context.read<AdminProvider>().updateStatsCustom(start, end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. HEADER ---
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 24,
              right: 24,
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              color: zampaBlack,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: zampaGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: zampaGreen.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: zampaGreen,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Panel Admin",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          "Zampa Café & Burguer",
                          style: TextStyle(
                            color: zampaYellow,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Botón cerrar sesión (Abre el diálogo)
                GestureDetector(
                  onTap: _handleLogout,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: zampaRed.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: zampaRed, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.power_settings_new,
                      color: zampaRed,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- 2. CONTENIDO SCROLLEABLE ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECCIÓN: VENTAS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Resumen de Ventas",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: zampaBlack,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _selectDateRange(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedPeriodIndex == -1
                                ? zampaBlack
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _selectedPeriodIndex == -1
                                  ? zampaBlack
                                  : zampaWhite,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: _selectedPeriodIndex == -1
                                    ? Colors.white
                                    : zampaBlack,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _selectedPeriodIndex == -1
                                    ? "Filtrado"
                                    : "Fechas",
                                style: TextStyle(
                                  color: _selectedPeriodIndex == -1
                                      ? Colors.white
                                      : zampaBlack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Toggle Switch interactivo
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: zampaWhite, width: 2),
                    ),
                    child: Row(
                      children: [
                        _buildPeriodTab("Diario", 0, context),
                        _buildPeriodTab("Semanal", 1, context),
                        _buildPeriodTab("Mensual", 2, context),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tarjetas de Estadísticas
                  adminProvider.isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(color: zampaGreen),
                          ),
                        )
                      : Row(
                          children: [
                            _buildStatCard(
                              "Ingresos",
                              "S/ ${adminProvider.totalVentas.toStringAsFixed(2)}",
                              Icons.monetization_on_rounded,
                              zampaGreen,
                            ),
                            const SizedBox(width: 16),
                            _buildStatCard(
                              "Pedidos",
                              "${adminProvider.totalPedidos}",
                              Icons.shopping_bag_rounded,
                              Colors.blueAccent,
                            ),
                          ],
                        ),

                  const SizedBox(height: 40),

                  // --- SECCIÓN: HERRAMIENTAS ---
                  const Text(
                    "Herramientas Principales",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: zampaBlack,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildActionTile(
                    title: "Gestión de Mi Carta",
                    subtitle:
                        "Actualiza precios, imágenes y stock al instante.",
                    icon: Icons.fastfood_rounded,
                    iconColor: zampaYellow,
                    onTap: () => context.push('/admin-menu'),
                  ),
                  const SizedBox(height: 16),

                  _buildActionTile(
                    title: "Ofertas y Promociones",
                    subtitle: "Crea descuentos para atraer más clientes.",
                    icon: Icons.local_fire_department_rounded,
                    iconColor: zampaRed,
                    onTap: () => context.push('/admin-offers'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildPeriodTab(String title, int index, BuildContext context) {
    bool isSelected = _selectedPeriodIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedPeriodIndex = index);
          String filter = index == 0
              ? 'Diario'
              : (index == 1 ? 'Semanal' : 'Mensual');
          context.read<AdminProvider>().updateStats(filter);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? zampaBlack : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: zampaWhite, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: zampaBlack,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: zampaWhite, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: zampaBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[400],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
