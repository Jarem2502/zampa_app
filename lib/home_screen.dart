import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart'; 

import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'services/location_service.dart'; 
import 'zampa_drawer.dart'; 
import 'models/product_model.dart';

const Color zampaGreen = Color(0xFF1A9956);
const Color zampaRed = Color(0xFFE53935);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  int _currentIndex = 0; 
  String _searchQuery = '';
  int _selectedCategoryId = 0; 
  final TextEditingController _searchController = TextEditingController();

  final LocationService _locationService = LocationService();
  bool _isInCity = false;
  bool _isLoadingLocation = true;

  final List<Map<String, dynamic>> _categories = [
    {'id': 0, 'name': 'Todos'},
    {'id': 1, 'name': 'Hamburguesas'},
    {'id': 2, 'name': 'Salchipapas'},
    {'id': 3, 'name': 'Sándwiches'},
    {'id': 4, 'name': 'Enchiladas'},
    {'id': 5, 'name': 'Especiales'},
    {'id': 6, 'name': 'Bebidas Frías'},
    {'id': 7, 'name': 'Cafés'},
    {'id': 8, 'name': 'Jugos'},
    {'id': 11, 'name': 'Calientes'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      _checkUserLocation(); 
    });
  }

  Future<void> _checkUserLocation() async {
    Position? pos = await _locationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _isInCity = pos != null ? _locationService.isUserInCity(pos) : false;
        _isLoadingLocation = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();
    final authProvider = context.watch<AuthProvider>();

    List<ProductModel> menuProducts = productProvider.products.where((p) => !p.isPromo).toList();
    List<ProductModel> promoProducts = productProvider.products.where((p) => p.isPromo).toList();
    
    List<ProductModel> topProducts = productProvider.products
        .where((p) => p.salesCount > 0)
        .take(4)
        .toList(); 

    if (_currentIndex == 0) {
      if (_searchQuery.isNotEmpty) {
        menuProducts = menuProducts.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      }
      if (_selectedCategoryId != 0) {
        menuProducts = menuProducts.where((p) => p.categoryId == _selectedCategoryId).toList();
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const ZampaDrawer(),
      appBar: _buildAppBar(cartProvider),
      body: Column(
        children: [
          if (_currentIndex == 0) ...[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hola, ${authProvider.user?.name.split(' ')[0] ?? 'Zampador'}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: '¿Qué vas a pedir hoy?',
                      prefixIcon: const Icon(Icons.search, color: zampaGreen),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              height: 50,
              padding: const EdgeInsets.only(left: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategoryId == category['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(category['name']),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      selected: isSelected,
                      selectedColor: zampaGreen,
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide.none,
                      onSelected: (selected) => setState(() => _selectedCategoryId = category['id']),
                    ),
                  );
                },
              ),
            ),
          ],

          if (_currentIndex == 1)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isLoadingLocation ? Colors.blue[50] : (_isInCity ? zampaGreen.withOpacity(0.1) : zampaRed.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isLoadingLocation ? Colors.blue[200]! : (_isInCity ? zampaGreen.withOpacity(0.3) : zampaRed.withOpacity(0.3))),
              ),
              child: Row(
                children: [
                  Icon(
                    _isLoadingLocation ? Icons.location_searching : (_isInCity ? Icons.location_on : Icons.location_off),
                    color: _isLoadingLocation ? Colors.blue : (_isInCity ? zampaGreen : zampaRed),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isLoadingLocation 
                          ? "Verificando tu ubicación para habilitar las ofertas..."
                          : (_isInCity 
                              ? "¡Estás en la zona! Disfruta de nuestras promociones exclusivas."
                              : "Lo sentimos, estas promociones son exclusivas para Huancayo."),
                      style: TextStyle(
                        color: _isLoadingLocation ? Colors.blue[800] : (_isInCity ? Colors.green[800] : Colors.red[800]),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (_currentIndex == 2)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Los Favoritos de la Gente 🔥", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87)),
                  SizedBox(height: 4),
                  Text("El ranking real basado en nuestros pedidos.", style: TextStyle(color: Colors.black54, fontSize: 14)),
                ],
              ),
            ),

          Expanded(
            child: productProvider.isLoading || (_currentIndex == 1 && _isLoadingLocation)
                ? const Center(child: CircularProgressIndicator(color: zampaGreen))
                : _buildCurrentTabContent(menuProducts, promoProducts, topProducts),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 0) _selectedCategoryId = 0; 
          });
        },
        selectedItemColor: zampaGreen,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'La Carta'),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Promos'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Top'),
        ],
      ),
    );
  }

  Widget _buildCurrentTabContent(List<ProductModel> menuProducts, List<ProductModel> promoProducts, List<ProductModel> topProducts) {
    if (_currentIndex == 0) {
      return menuProducts.isEmpty ? _buildEmptyState("No hay productos en esta categoría.") : _buildGrid(menuProducts);
    } else if (_currentIndex == 1) {
      if (!_isInCity) return _buildEmptyState("Estás fuera de la zona de promociones.", icon: Icons.location_off);
      return promoProducts.isEmpty ? _buildEmptyState("No hay promociones activas por ahora.", icon: Icons.sentiment_dissatisfied) : _buildGrid(promoProducts);
    } else {
      return topProducts.isEmpty ? _buildEmptyState("Aún no hay suficientes ventas para generar el ranking.", icon: Icons.leaderboard) : _buildGrid(topProducts, isTopList: true);
    }
  }

  Widget _buildGrid(List<ProductModel> products, {bool isTopList = false}) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        // 🔥 CORRECCIÓN 1: De 0.72 a 0.60 (Hace la tarjeta más alta para que el texto respire)
        childAspectRatio: 0.60, 
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index], rank: isTopList ? (index + 1) : null);
      },
    );
  }

  Widget _buildProductCard(ProductModel product, {int? rank}) {
    return GestureDetector(
      onTap: () => context.push('/detalle', extra: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    product.imageUrl ?? 'https://ui-avatars.com/api/?name=Zampa&background=1A9956&color=fff',
                    // 🔥 CORRECCIÓN 2: Reducimos la altura de la imagen para que sobre más espacio abajo
                    height: 105, 
                    width: double.infinity, 
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(height: 105, color: Colors.grey[100], child: const Center(child: Icon(Icons.image, color: Colors.grey))),
                  ),
                  if (rank != null)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)]),
                        child: Text("🏆 #$rank Favorito", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  if (product.isPromo && rank == null)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: zampaRed, borderRadius: BorderRadius.circular(8)),
                        child: const Text("PROMO", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0), // 🔥 CORRECCIÓN 3: Ajustamos el padding de 12 a 10
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name, 
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14), 
                          maxLines: 2, // 🔥 Permitimos hasta 2 líneas por si el nombre es largo
                          overflow: TextOverflow.ellipsis
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.description.isEmpty ? "Delicioso producto preparado al momento." : product.description, 
                          style: const TextStyle(color: Colors.black54, fontSize: 11), 
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.isPromo)
                                Text("S/${product.price.toStringAsFixed(2)}", style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 11)),
                              Text(
                                "S/${(product.isPromo ? product.promoPrice : product.price).toStringAsFixed(2)}", 
                                style: const TextStyle(color: zampaGreen, fontWeight: FontWeight.w900, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<CartProvider>().addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${product.name} agregado"), backgroundColor: zampaGreen, duration: const Duration(seconds: 1)));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6), 
                            decoration: const BoxDecoration(color: zampaGreen, shape: BoxShape.circle), 
                            child: const Icon(Icons.add, color: Colors.white, size: 20)
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, {IconData icon = Icons.fastfood_outlined}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(CartProvider cartProvider) {
    return AppBar(
      backgroundColor: Colors.white, elevation: 0,
      leading: IconButton(icon: const Icon(Icons.menu_rounded, color: Colors.black, size: 28), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
      title: Image.asset('assets/zampalogo.png', height: 35, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Text("ZAMPA", style: TextStyle(color: zampaGreen, fontWeight: FontWeight.w900, fontSize: 24))),
      centerTitle: true,
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black, size: 26), onPressed: () => context.push('/carrito')),
            if (cartProvider.itemCount > 0)
              Positioned(
                top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: zampaRed, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text('${cartProvider.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}