import 'package:flutter/material.dart';

class TabPromotions extends StatefulWidget {
  const TabPromotions({super.key});

  @override
  State<TabPromotions> createState() => _TabPromotionsState();
}

class _TabPromotionsState extends State<TabPromotions> {
  bool _hasPermission = false;

  @override
  Widget build(BuildContext context) {
    return _hasPermission ? _buildPromotionsList() : _buildPermissionRequest();
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text(
            "Sin promociones cercanas",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Activa tu ubicación para ver ofertas exclusivas en tu zona.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _showSimulationDialog,
            icon: const Icon(Icons.my_location, color: Colors.white),
            label: const Text("Activar Ubicación", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
        const Text("Ofertas Relámpago ⚡", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _buildPromoCard(
          title: "Pack Royal Familiar",
          description: "2 Hamburguesas Royal + 2 Gaseosas + Papas",
          oldPrice: "S/ 45.00",
          newPrice: "S/ 32.90",
          color: Colors.orange.shade50,
          icon: Icons.lunch_dining,
        ),
        _buildPromoCard(
          title: "Hora del Frappé",
          description: "2x1 en todos los Frappés de Oreo y Moka",
          oldPrice: "S/ 24.00",
          newPrice: "S/ 12.00",
          color: Colors.brown.shade50,
          icon: Icons.local_cafe,
        ),
      ],
    );
  }

  Widget _buildLocationBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green),
          SizedBox(width: 8),
          Text("Ubicación detectada: Huancayo, Centro", 
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  void _showSimulationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("¿Permitir ubicación?"),
        content: const Text("Usamos tu ubicación para mostrarte las mejores ofertas de Digimon."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No permitir")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _hasPermission = true); // Esto activará _buildPromotionsList()
            },
            child: const Text("Permitir", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
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