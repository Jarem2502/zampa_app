import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'zampa_data.dart'; // Importamos tu data real

class TabRecommendations extends StatelessWidget {
  const TabRecommendations({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de nombres para filtrar tus recomendados
    final bestSellerNames = [
      'Sándwich de pollo con durazno',
      'Hamburguesa a lo pobre',
      'Hamburguesa clásica artesanal',
      'Hamburguesa de pollo',
      'Sándwich de Pollo Desmenuzado',
      'Promo Zampa',
      'Combo Salchi Pollo + Gaseosa',
      'Salchipapa a lo pobre',
      'Filete de Pollo + Bebida',
    ];

    // Filtramos de la lista global allProducts
    final recomendados = allProducts.where((p) {
      return bestSellerNames.any((name) => p.name.contains(name));
    }).toList();

    return Column(
      children: [
        // --- ENCABEZADO DESTACADO ---
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.workspace_premium, color: Colors.orange, size: 32),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TOP SELECCIÓN",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 1.5),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Favoritos de la Gente",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87, height: 1.1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // --- LISTA DE PRODUCTOS ---
        Expanded(
          child: ListView.builder(
            itemCount: recomendados.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final product = recomendados[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  onTap: () {
                    // --- CAMBIO GO_ROUTER ---
                    context.push('/detalle', extra: product);
                  },
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.star_rounded, color: Colors.orange, size: 34),
                  ),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 8),
                      _buildBadge(),
                    ],
                  ),
                  trailing: Text("S/${product.price.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.green[50], 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: Colors.green.shade200)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up, size: 14, color: Colors.green),
          SizedBox(width: 4),
          Text("Más Vendido", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}