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

import 'services/pusher_config.dart';
import 'dart:convert';

const Color zampaGreen = Color(0xFF1A9956);
const Color zampaRed = Color(0xFFE53935);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PusherConfig _pusherConfig = PusherConfig();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentIndex = 0;
  String _searchQuery = '';
  int _selectedCategoryId = 0;
  final TextEditingController _searchController = TextEditingController();

  final LocationService _locationService = LocationService();
  bool _isInCity = false;
  bool _isLoadingLocation = true;
  bool _isLocationServiceEnabled = true;
  bool _hasLocationPermission = false;
  bool _isPermissionDeniedForever = false;

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

    _pusherConfig.initPusher(
      channelName: "canal-promos",
      eventName: "nueva-promo",
      onEventTriggered: (event) {
        if (!mounted) return;

        dynamic data;
        if (event.data is String) {
          data = jsonDecode(event.data.toString());
        } else {
          data = event.data;
        }

        String mensajePromo =
            data['mensaje'] ?? "¡Tenemos nuevas ofertas para ti!";

        _mostrarAlertaPromo(mensajePromo);
        context.read<ProductProvider>().fetchProducts();
      },
    );
  }

  Future<void> _checkUserLocation() async {
    if (mounted) {
      setState(() {
        _isLoadingLocation = true;
      });
    }

    final bool serviceEnabled = await _locationService
        .isLocationServiceEnabled();

    LocationPermission permission = await _locationService
        .checkPermissionStatus();

    if (permission == LocationPermission.denied) {
      permission = await _locationService.requestPermissionIfNeeded();
    }

    final bool hasPermission = _locationService.hasGrantedPermission(
      permission,
    );
    final bool deniedForever = _locationService.isDeniedForever(permission);

    Position? pos;
    bool inCity = false;

    if (serviceEnabled && hasPermission && !deniedForever) {
      pos = await _locationService.getCurrentLocation();
      inCity = pos != null ? _locationService.isUserInCity(pos) : false;
    }

    if (mounted) {
      setState(() {
        _isLocationServiceEnabled = serviceEnabled;
        _hasLocationPermission = hasPermission;
        _isPermissionDeniedForever = deniedForever;
        _isInCity = inCity;
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _handleLocationAction() async {
    if (_isPermissionDeniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    if (!_isLocationServiceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    await _checkUserLocation();
  }

  String _locationButtonText() {
    if (_isPermissionDeniedForever) return 'Abrir ajustes';
    if (!_isLocationServiceEnabled) return 'Activar ubicación';
    if (!_hasLocationPermission) return 'Permitir ubicación';
    return 'Reintentar';
  }

  IconData _locationButtonIcon() {
    if (_isPermissionDeniedForever) return Icons.settings_rounded;
    if (!_isLocationServiceEnabled) return Icons.location_searching_rounded;
    if (!_hasLocationPermission) return Icons.my_location_rounded;
    return Icons.refresh_rounded;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pusherConfig.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();
    final authProvider = context.watch<AuthProvider>();

    List<ProductModel> menuProducts = productProvider.products
        .where((p) => !p.isActivePromo)
        .toList();

    List<ProductModel> promoProducts = productProvider.products
        .where((p) => p.isActivePromo)
        .toList();

    List<ProductModel> topProducts = productProvider.products
        .where((p) => p.salesCount > 0)
        .take(4)
        .toList();

    if (_currentIndex == 0) {
      if (_searchQuery.isNotEmpty) {
        menuProducts = menuProducts
            .where(
              (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();
      }

      if (_selectedCategoryId != 0) {
        menuProducts = menuProducts
            .where((p) => p.categoryId == _selectedCategoryId)
            .toList();
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
                      onSelected: (_) {
                        setState(() => _selectedCategoryId = category['id']);
                      },
                    ),
                  );
                },
              ),
            ),
          ],

          if (_currentIndex == 2)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Los Favoritos de la Gente 🔥",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "El ranking real basado en nuestros pedidos.",
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),

          Expanded(
            child:
                productProvider.isLoading ||
                    (_currentIndex == 1 && _isLoadingLocation)
                ? const Center(
                    child: CircularProgressIndicator(color: zampaGreen),
                  )
                : _buildCurrentTabContent(
                    menuProducts,
                    promoProducts,
                    topProducts,
                  ),
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

          if (index == 1) {
            _checkUserLocation();
          }
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

  Widget _buildCurrentTabContent(
    List<ProductModel> menuProducts,
    List<ProductModel> promoProducts,
    List<ProductModel> topProducts,
  ) {
    if (_currentIndex == 0) {
      return menuProducts.isEmpty
          ? _buildEmptyState("No hay productos en esta categoría.")
          : _buildGrid(menuProducts);
    } else if (_currentIndex == 1) {
      if (!_isLocationServiceEnabled || !_hasLocationPermission) {
        return _buildPromoPermissionState();
      }

      if (!_isInCity) {
        return _buildPromoOutOfZoneState();
      }

      return _buildPromoAvailableState(promoProducts);
    } else {
      return topProducts.isEmpty
          ? _buildEmptyState(
              "Aún no hay suficientes ventas para generar el ranking.",
              icon: Icons.leaderboard_outlined,
            )
          : _buildGrid(topProducts, isTopList: true);
    }
  }

  Widget _buildPromoAvailableState(List<ProductModel> promoProducts) {
    if (promoProducts.isEmpty) {
      return _buildEmptyState(
        "No hay promociones activas por ahora.",
        icon: Icons.sentiment_dissatisfied_outlined,
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF23B567), zampaGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: zampaGreen.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Promociones para ti",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Aprovecha descuentos exclusivos disponibles en tu zona.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            children: [
              const Icon(Icons.verified_rounded, color: zampaGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                "Ubicación validada correctamente",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildGrid(promoProducts)),
      ],
    );
  }

  Widget _buildPromoPermissionState() {
    final bool needsSettings = _isPermissionDeniedForever;
    final bool needsGps = !_isLocationServiceEnabled;

    IconData mainIcon = needsSettings
        ? Icons.admin_panel_settings_outlined
        : needsGps
        ? Icons.location_disabled_outlined
        : Icons.location_searching_rounded;

    String title = needsSettings
        ? "Activa el permiso de ubicación"
        : needsGps
        ? "Enciende tu ubicación"
        : "Permite tu ubicación";

    String subtitle = needsSettings
        ? "Para mostrarte promociones exclusivas, necesitamos que habilites el permiso desde los ajustes de tu teléfono."
        : needsGps
        ? "Activa la ubicación del dispositivo para validar si estás dentro de la zona de promociones."
        : "Necesitamos acceder a tu ubicación para verificar si puedes ver las promociones disponibles.";

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: zampaGreen.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: zampaGreen.withOpacity(0.15),
                  width: 2,
                ),
              ),
              child: Icon(mainIcon, size: 52, color: zampaGreen),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _handleLocationAction,
                icon: Icon(
                  _locationButtonIcon(),
                  color: Colors.white,
                  size: 22,
                ),
                label: Text(
                  _locationButtonText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: zampaGreen,
                  elevation: 8,
                  shadowColor: zampaGreen.withOpacity(0.30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: _checkUserLocation,
              child: const Text(
                "Volver a comprobar",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoOutOfZoneState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: zampaRed.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: zampaRed.withOpacity(0.15), width: 2),
              ),
              child: const Icon(
                Icons.location_off_outlined,
                size: 52,
                color: zampaRed,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              "Promociones no disponibles en tu zona",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Tus permisos están correctos, pero por ahora estas promociones son exclusivas para usuarios dentro de Huancayo.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _checkUserLocation,
                icon: const Icon(Icons.refresh_rounded, color: zampaGreen),
                label: const Text(
                  "Volver a comprobar ubicación",
                  style: TextStyle(
                    color: zampaGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: zampaGreen.withOpacity(0.35),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<ProductModel> products, {bool isTopList = false}) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(
          products[index],
          rank: isTopList ? (index + 1) : null,
        );
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
            Expanded(
              flex: 45,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      product.imageUrl ??
                          'https://ui-avatars.com/api/?name=Zampa&background=1A9956&color=fff',
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    ),
                    if (rank != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            "🏆 #$rank Favorito",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    if (product.isActivePromo && rank == null)
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
            ),
            Expanded(
              flex: 55,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
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
                    Expanded(
                      child: Text(
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
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (product.isActivePromo)
                                Text(
                                  "S/${product.price.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 11,
                                  ),
                                ),
                              Text(
                                "S/${product.currentPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: zampaGreen,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
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
                            padding: const EdgeInsets.all(8),
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

  Widget _buildEmptyState(
    String message, {
    IconData icon = Icons.fastfood_outlined,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(CartProvider cartProvider) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.black, size: 28),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Image.asset(
        'assets/zampalogo.png',
        height: 35,
        fit: BoxFit.contain,
        errorBuilder: (c, e, s) => const Text(
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
    );
  }

  void _mostrarAlertaPromo(String contenido) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE53935), width: 2),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: Color(0xFFE53935),
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                "¡NUEVA OFERTA!",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFDB0212),
                ),
              ),
            ],
          ),
          content: Text(
            contenido,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "¡La quiero!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _currentIndex = 1);
                _checkUserLocation();
              },
            ),
          ],
        );
      },
    );
  }
}
