import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'models/product_model.dart';

const Color zampaGreen = Color(0xFF1A9956);
const Color zampaRed = Color(0xFFE53935);

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final Map<int, bool> _availabilityState = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  void _editPriceDialog(BuildContext context, ProductModel product) {
    final TextEditingController priceCtrl = TextEditingController(text: product.price.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Editar Precio: ${product.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: TextField(
          controller: priceCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Nuevo Precio (S/)",
            prefixIcon: const Icon(Icons.attach_money, color: zampaGreen),
            filled: true, fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Precio actualizado (Simulación)"), backgroundColor: zampaGreen));
            },
            style: ElevatedButton.styleFrom(backgroundColor: zampaGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text("Guardar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => context.pop()),
          ),
        ),
        title: const Text("Mi Carta", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: zampaGreen))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: productProvider.products.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final product = productProvider.products[index];
                bool isAvailable = _availabilityState[product.id] ?? true;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl ?? 'https://ui-avatars.com/api/?name=Zampa',
                          width: 60, height: 60, fit: BoxFit.cover,
                          errorBuilder: (c,e,s) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.fastfood, color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, decoration: isAvailable ? null : TextDecoration.lineThrough)),
                            const SizedBox(height: 4),
                            Text("S/ ${product.price.toStringAsFixed(2)}", style: const TextStyle(color: zampaGreen, fontWeight: FontWeight.w900, fontSize: 15)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () => _editPriceDialog(context, product),
                      ),
                      Switch(
                        value: isAvailable,
                        activeColor: zampaGreen,
                        onChanged: (val) {
                          setState(() => _availabilityState[product.id] = val);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}