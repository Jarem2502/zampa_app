import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';
import 'package:go_router/go_router.dart';

class TabPromotions extends StatefulWidget {
  const TabPromotions({super.key});

  @override
  State<TabPromotions> createState() => _TabPromotionsState();
}

class _TabPromotionsState extends State<TabPromotions> {
  final LocationService _locationService = LocationService();
  bool _isLoading = true;
  bool _hasPermission = false;
  bool _isInCity = false;
  List<ProductModel> _promoProducts = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // 1. Verificamos GPS
    Position? position = await _locationService.getCurrentLocation();

    if (position != null) {
      _hasPermission = true;
      _isInCity = _locationService.isUserInCity(position);
    }

    // 2. Si está en la ciudad, descargamos los productos en oferta
    if (_isInCity) {
      final allProducts = await ProductService().getProducts();
      // Filtramos solo los que el Admin marcó como "Oferta"
      _promoProducts = allProducts.where((p) => p.isPromo).toList();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    if (!_hasPermission) {
      return const Center(
        child: Text(
          "Necesitamos acceso a tu ubicación para mostrarte ofertas exclusivas.",
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!_isInCity) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "¡Oh no!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Las ofertas son exclusivas para clientes en la zona de Huancayo. ¡Visítanos pronto!",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (_promoProducts.isEmpty) {
      return const Center(
        child: Text("No hay promociones activas en este momento."),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _promoProducts.length,
      itemBuilder: (context, index) {
        final prod = _promoProducts[index];
        return _buildPromoCard(prod);
      },
    );
  }

  Widget _buildPromoCard(ProductModel product) {
    return InkWell(
      onTap: () => context.push('/detalle', extra: product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade100, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: product.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.fastfood, color: Colors.black26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "OFERTA GPS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        "S/${product.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "S/${product.promoPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 18,
                        ),
                      ),
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
}
