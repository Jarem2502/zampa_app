import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

const Color zampaGreen = Color(0xFF1A9956);
const Color zampaRed = Color(0xFFE53935);

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedPeriodIndex = 0; 

  // 🔥 FUNCIÓN PARA CERRAR SESIÓN
  void _handleLogout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) context.go('/'); // Te regresa al inicio/login
  }

  Future<void> _selectDate(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: zampaGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER CURVO OSCURO ---
            Container(
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Panel de Control", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      SizedBox(height: 4),
                      Text("Zampa Café & Burguer", style: TextStyle(color: zampaGreen, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      // Calendario
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.calendar_month, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 🔥 Botón Rápido de Cerrar Sesión
                      GestureDetector(
                        onTap: _handleLogout,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: zampaRed.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.power_settings_new, color: zampaRed),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- RESUMEN DE VENTAS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Resumen de Ventas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      children: [
                        _buildPeriodTab("Diario", 0),
                        _buildPeriodTab("Semanal", 1),
                        _buildPeriodTab("Mensual", 2),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildStatCard("Ingresos Totales", "S/ 36.00", Icons.attach_money, zampaGreen),
                      const SizedBox(width: 16),
                      _buildStatCard("Pedidos Hoy", "2", Icons.shopping_bag_outlined, Colors.blue),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- GESTIÓN RÁPIDA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Gestión Rápida", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 16),
                  
                  _buildActionTile(
                    title: "Ofertas y Promociones",
                    subtitle: "Activa o desactiva descuentos",
                    icon: Icons.local_offer,
                    iconColor: zampaRed,
                    onTap: () => context.push('/admin-offers'),
                  ),
                  const SizedBox(height: 12),
                  // 🔥 Restaurado: Mi Carta
                  _buildActionTile(
                    title: "Mi Carta",
                    subtitle: "Edita precios y disponibilidad",
                    icon: Icons.fastfood,
                    iconColor: Colors.orange,
                    onTap: () => context.push('/admin-menu'),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // 🔥 BOTÓN GRANDE DE CERRAR SESIÓN
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout, color: zampaRed),
                      label: const Text("Cerrar Sesión", style: TextStyle(color: zampaRed, fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: zampaRed.withOpacity(0.5), width: 2)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(String title, int index) {
    bool isSelected = _selectedPeriodIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriodIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
          ),
          child: Center(
            child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({required String title, required String subtitle, required IconData icon, required Color iconColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}