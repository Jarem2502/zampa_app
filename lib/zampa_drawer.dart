import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ZampaDrawer extends StatelessWidget {
  const ZampaDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFD9D9D9), // Fondo gris de tu diseño
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 60),

            // OPCIONES DEL MENÚ
            _buildDrawerItem(
              Icons.restaurant_menu,
              'Menú',
              onTap: () => context.pop(), // Solo cierra el drawer
            ),

            _buildDrawerItem(
              Icons.receipt_long,
              'Mis Pedidos',
              onTap: () {
                context.pop(); // Cierra drawer
                context.push('/orders');
              },
            ),

            _buildDrawerItem(
              Icons.smart_toy_outlined,
              'Ayuda Zampa',
              onTap: () {
                context.pop();
                context.push('/chatbot');
              },
            ),

            _buildDrawerItem(
              Icons.share_outlined,
              'Invitar',
              onTap: () {
                context.pop();
                context.push('/invite');
              },
            ),

            _buildDrawerItem(
              Icons.chat_bubble_outline,
              'Comentarios',
              onTap: () {
                context.pop();
                context.push('/feedback');
              },
            ),

            _buildDrawerItem(
              Icons.accessibility_new,
              'Acerca de Nosotros',
              onTap: () {
                context.pop();
                context.push('/about');
              },
            ),

            _buildDrawerItem(
              Icons.person_outline,
              'Mi Perfil',
              onTap: () {
                context.pop();
                context.push('/profile');
              },
            ),

            const SizedBox(height: 20),

            // BOTÓN CERRAR SESIÓN (Rojo en tu diseño)
            Container(
              color: const Color(0xFFA95C5C),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.black),
                title: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  // context.go('/') limpia el historial y vuelve al Login
                  context.go('/');
                },
              ),
            ),

            const SizedBox(height: 40),

            // FOOTER REDES SOCIALES
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Síguenos en:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _socialIcon(Icons.facebook),
                      const SizedBox(width: 15),
                      _socialIcon(Icons.camera_alt),
                      const SizedBox(width: 15),
                      _socialIcon(Icons.music_note),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para items del menú
  Widget _buildDrawerItem(IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  // Widget auxiliar para iconos de redes
  Widget _socialIcon(IconData icon) {
    return Icon(icon, size: 30, color: Colors.black87);
  }
}