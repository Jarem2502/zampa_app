import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

// 🔥 COLORES OFICIALES ZAMPA
const Color zampaGreen = Color(0xFF1A9956);
const Color zampaRed = Color(0xFFE53935);

class ZampaDrawer extends StatelessWidget {
  const ZampaDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // --- 1. HEADER DEL DRAWER (Degradado Verde Zampa) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              // 🔥 ADIÓS NEGRO: Hola degradado fresco
              gradient: LinearGradient(
                colors: [Color(0xFF23B567), zampaGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(topRight: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey[100],
                    backgroundImage: user?.avatar != null
                        ? NetworkImage(user!.avatar!)
                        : null,
                    child: user?.avatar == null
                        ? const Icon(Icons.person, size: 35, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Invitado',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'Inicia sesión para más beneficios',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          // --- 2. OPCIONES DEL MENÚ ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_rounded,
                  title: 'Inicio',
                  onTap: () => context.pop(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Mi Perfil',
                  onTap: () {
                    context.pop();
                    context.push('/profile');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.receipt_long_rounded,
                  title: 'Mis Pedidos',
                  onTap: () {
                    context.pop();
                    context.push('/orders');
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Divider(color: Colors.black12, height: 1),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.support_agent_rounded,
                  title: 'Ayuda Zampa',
                  onTap: () {
                    context.pop();
                    context.push('/chatbot');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.card_giftcard_rounded,
                  title: 'Invitar Amigos',
                  onTap: () {
                    context.pop();
                    context.push('/invite');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'Sobre Nosotros',
                  onTap: () {
                    context.pop();
                    context.push('/about');
                  },
                ),
              ],
            ),
          ),

          // --- 3. FOOTER ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(30),
              ),
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Síguenos en:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _socialIcon(Icons.facebook, const Color(0xFF1877F2)),
                      const SizedBox(width: 12),
                      _socialIcon(Icons.camera_alt, const Color(0xFFE4405F)),
                      const SizedBox(width: 12),
                      _socialIcon(Icons.music_note, Colors.black),
                    ],
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () async {
                      await authProvider.logout();
                      if (context.mounted) context.go('/');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: zampaRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: zampaRed,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            color: zampaRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        hoverColor: Colors.grey[100],
        splashColor: Colors.grey[200],
        onTap: onTap,
      ),
    );
  }

  Widget _socialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
