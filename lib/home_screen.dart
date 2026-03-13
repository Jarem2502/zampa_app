import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'zampa_drawer.dart';
import 'models/product_model.dart';

// 🔥 COLORES OFICIALES ZAMPA
const Color zampaGreen = Color(0xFF1A9956);
const Color zampaRed = Color(0xFFE53935);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Controles de navegación y filtros
  int _currentIndex = 0; // 0: Carta, 1: Promos, 2: Top
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  final TextEditingController _searchController = TextEditingController();

  // Filtros dinámicos (Puedes agregar más si lo necesitas)
  final List<String> _categories = [
    'Todos',
    'Hamburguesas',
    'Salchipapas',
    'Bebidas',
    'Extras',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
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

    // 1. Filtrar lista de productos base según la Pestaña actual (Menú de abajo)
    List<ProductModel> displayProducts = productProvider.products;

    if (_currentIndex == 1) {
      displayProducts = displayProducts.where((p) => p.isPromo).toList();
    } else if (_currentIndex == 2) {
      displayProducts = displayProducts.take(6).toList(); // Simulamos los Top
    } else {
      displayProducts = displayProducts
          .where((p) => !p.isPromo)
          .toList(); // Carta normal
    }

    // 2. Filtrar por Buscador
    if (_searchQuery.isNotEmpty) {
      displayProducts = displayProducts
          .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // 3. Filtrar por Categoría (Buscamos la palabra clave en el nombre o categoría si aplica)
    if (_selectedCategory != 'Todos') {
      // Usamos un filtro inteligente para que coincida con tus salchipapas/hamburguesas
      String keyword = _selectedCategory == 'Salchipapas'
          ? 'salchi'
          : _selectedCategory.toLowerCase();
      displayProducts = displayProducts.where((p) {
        // Asumiendo que categoryId 1 es hamburguesas, 2 salchipapas (Ajusta si los conoces)
        // O lo buscamos directamente en el nombre del producto como medida infalible
        return p.name.toLowerCase().contains(keyword.replaceAll('s', ''));
      }).toList();
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const ZampaDrawer(),

      // --- APP BAR Y LOGO LOCAL ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.black, size: 28),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Image.asset(
          'assets/zampalogo.png', // 🔥 TU LOGO LOCAL RESTAURADO
          height: 35,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Text(
            "ZAMPA",
            style: TextStyle(
              color: zampaGreen,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.black,
                  size: 26,
                ),
                onPressed: () => context.push('/carrito'),
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: zampaRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      // --- CUERPO PRINCIPAL ---
      body: Column(
        children: [
          // BIENVENIDA Y BUSCADOR
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hola, ${authProvider.user?.name.split(' ')[0] ?? 'Zampador'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: '¿Qué vas a pedir hoy?',
                    hintStyle: TextStyle(color: Colors.grey[400]),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- FILTRO DE CATEGORÍAS HORIZONTAL ---
          // Lo ocultamos si estamos en Promociones o Top para no saturar
          if (_currentIndex == 0)
            Container(
              color: Colors.white,
              height: 50,
              padding: const EdgeInsets.only(left: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(category),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      selected: isSelected,
                      selectedColor: zampaGreen,
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide.none,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                    ),
                  );
                },
              ),
            ),

          // --- AVISO DE UBICACIÓN (Solo en Promos) ---
          if (_currentIndex == 1)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: zampaRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: zampaRed.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: zampaRed, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Mostrando promociones exclusivas cerca a tu ubicación.",
                      style: TextStyle(
                        color: Colors.red[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // --- GRILLA DE PRODUCTOS ---
          Expanded(
            child: productProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: zampaGreen),
                  )
                : displayProducts.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.72, // Proporción balanceada
                        ),
                    itemCount: displayProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(displayProducts[index]);
                    },
                  ),
          ),
        ],
      ),

      // --- BOTONES DE NAVEGACIÓN INFERIOR RESTAURADOS ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _selectedCategory =
                'Todos'; // Reseteamos el filtro al cambiar de tab
          });
        },
        selectedItemColor: zampaGreen,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'La Carta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Promos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Top'),
        ],
      ),
    );
  }

  // Tarjeta de Producto (Corregida para que las imágenes no se deformen)
  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () => context.push('/detalle', extra: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGEN FIJA: Evita que la foto se estire o corte mal
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.network(
                    product.imageUrl ??
                        'https://ui-avatars.com/api/?name=Zampa&background=1A9956&color=fff',
                    height:
                        120, // 🔥 Altura controlada para perfecta proporción
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      height: 120,
                      color: Colors.grey[100],
                      child: const Center(
                        child: Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  if (product.isPromo)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: zampaRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "PROMO",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // DETALLES DEL PRODUCTO
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // 🔥 Empuja el precio hacia abajo
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.description.isEmpty
                              ? "Delicioso producto preparado al momento."
                              : product.description,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // PRECIO Y BOTÓN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.isPromo)
                              Text(
                                "S/${product.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 11,
                                ),
                              ),
                            Text(
                              "S/${(product.isPromo ? product.promoPrice : product.price).toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: zampaGreen,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<CartProvider>().addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${product.name} agregado"),
                                backgroundColor: zampaGreen,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: zampaGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fastfood_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No encontramos productos.",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
