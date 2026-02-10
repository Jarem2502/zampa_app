import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'zampa_data.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/detalle', extra: product),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFDDE0FF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Hero(
                tag: 'prod_${product.name}',
                // Aquí está el cambio: Image.network para URLs
                child: Image.network(
                  product.imagePath,
                  errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Text(
              'S/${product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}