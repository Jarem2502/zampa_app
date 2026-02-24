import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart'; // 🔥 Importamos tu nuevo servicio

class TabPromotions extends StatefulWidget {
  const TabPromotions({super.key});

  @override
  State<TabPromotions> createState() => _TabPromotionsState();
}

class _TabPromotionsState extends State<TabPromotions> {
  final LocationService _locationService = LocationService();
  bool _isLoading = false;
  bool _hasPermission = false;
  bool _isInCity = false;
  String _currentCity = "Detectando...";

  // Función real para obtener ubicación
  Future<void> _handleLocationPermission() async {
    setState(() => _isLoading = true);

    Position? position = await _locationService.getCurrentLocation();

    if (position != null) {
      bool inCity = _locationService.isUserInCity(position);
      setState(() {
        _hasPermission = true;
        _isInCity = inCity;
        _currentCity = inCity ? "Huancayo, Centro" : "Fuera de zona de servicio";
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo obtener la ubicación. Revisa tus permisos.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.green));
    }

    return _hasPermission ? _buildPromotionsList() : _buildPermissionRequest();
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on_outlined, size: 80, color: Colors.green[200]),
          const SizedBox(height: 20),
          const Text(
            "Ofertas Exclusivas",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Zampa ofrece promociones especiales según tu ubicación en la ciudad.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _handleLocationPermission, // 🔥 Ahora llama a la lógica real
            icon: const Icon(Icons.my_location, color: Colors.white),
            label: const Text("Verificar Ubicación", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionsList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildLocationBanner(),
        
        // --- LÓGICA DINÁMICA ---
        if (_isInCity) ...[
          const Text("Ofertas Relámpago en Huancayo ⚡", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildPromoCard(
            title: "Pack Zampa Familiar",
            description: "2 Hamburguesas Royal + 2 Gaseosas + Papas",
            oldPrice: "S/ 45.00",
            newPrice: "S/ 32.90",
            color: Colors.orange.shade50,
            icon: Icons.lunch_dining,
          ),
          _buildPromoCard(
            title: "Zampa 2x1 en Frappés",
            description: "Aplica en Oreo y Moka (Solo Tienda)",
            oldPrice: "S/ 24.00",
            newPrice: "S/ 12.00",
            color: Colors.brown.shade50,
            icon: Icons.local_cafe,
          ),
        ] else ...[
          _buildOutOfZoneMessage(),
        ],
      ],
    );
  }

  Widget _buildLocationBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _isInCity ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isInCity ? Colors.green.shade200 : Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            _isInCity ? Icons.location_on : Icons.location_off, 
            size: 18, 
            color: _isInCity ? Colors.green : Colors.red
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Ubicación: $_currentCity", 
              style: TextStyle(
                color: _isInCity ? Colors.green[800] : Colors.red[800], 
                fontWeight: FontWeight.bold, 
                fontSize: 13
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfZoneMessage() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(Icons.sentiment_dissatisfied, size: 60, color: Colors.grey[400]),
        const SizedBox(height: 16),
        const Text(
          "Lo sentimos, Jarem",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Estas promociones solo están disponibles para usuarios dentro de Huancayo.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPromoCard({required String title, required String description, required String oldPrice, required String newPrice, required Color color, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.black54),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 1),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(oldPrice, style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 8),
                    Text(newPrice, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}