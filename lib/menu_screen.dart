import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// --- IMPORTS DE TUS COMPONENTES ---
import 'zampa_drawer.dart';
import 'tab_menu.dart';
import 'tab_recommendations.dart';
import 'tab_promotions.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const Icon(Icons.restaurant_menu, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              _getTitle(_selectedIndex),
              style: const TextStyle(color: Colors.white),
            ),
            const Spacer(),
            // Asegúrate de que el asset existe en pubspec.yaml
            Image.asset('assets/zampalogo.png', height: 30, errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.fastfood, color: Colors.white); // Icono de respaldo si falla la imagen
            }),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.red),
            onPressed: () => context.push('/carrito'),
          ),
        ],
      ),
      
      drawer: const ZampaDrawer(),

      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          TabMenu(),            // Asegúrate de que este archivo esté correcto
          TabRecommendations(), // Usa la clase del archivo importado
          TabPromotions(),      // Usa la clase del archivo importado
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Menú'),
          BottomNavigationBarItem(icon: Icon(Icons.star_outline), label: 'Recomendados'),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer_outlined), label: 'Promociones'),
        ],
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Menú';
      case 1: return 'Favoritos';
      case 2: return 'Promociones';
      default: return 'Zampa';
    }
  }
}

// --- NOTA IMPORTANTE ---
// HE BORRADO LAS CLASES TabPromotions y TabRecommendations DE AQUÍ ABAJO.
// Debes asegurarte de que en sus archivos (tab_promotions.dart y tab_recommendations.dart)
// las clases empiecen así: "class TabPromotions extends StatelessWidget {"