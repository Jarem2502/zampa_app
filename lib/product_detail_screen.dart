import 'package:flutter/material.dart';
import 'package:flutter_application_zampa/providers/cart_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  final TextEditingController _notesController = TextEditingController();

  void _increment() {
    setState(() {
      quantity++;
    });
  }

  void _decrement() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos el total en tiempo real para mostrar en el botón
    double totalPrice = widget.product.price * quantity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. ZONA SUPERIOR (Imagen + Botón Volver)
          Stack(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                color: const Color(0xFFF5F5F5),
                child: Image.network(
                  widget.product.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => const Icon(
                    Icons.fastfood,
                    size: 100,
                    color: Colors.black26,
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      context.pop();
                    },
                  ),
                ),
              ),
            ],
          ),

          // 2. DETALLE DEL PRODUCTO
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                      ),
                      Text(
                        "S/${widget.product.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.product.description.isNotEmpty
                        ? widget.product.description
                        : "Delicioso producto preparado al momento con los mejores ingredientes.",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 20),
                  const Text(
                    "¿Alguna instrucción especial?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      hintText: "Ej: Sin cebolla, poco hielo...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),

          // 3. BARRA INFERIOR (Controles y Botón)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Contador
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _decrement,
                        icon: const Icon(Icons.remove, size: 20),
                        color: Colors.black,
                      ),
                      Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _increment,
                        icon: const Icon(Icons.add, size: 20),
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Botón Agregar Real
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 1. AGREGAMOS EL PRODUCTO AL PROVIDER
                      // read() se usa en botones porque solo necesitamos mandar una acción, no escuchar cambios constantes
                      context.read<CartProvider>().addToCart(
                        widget.product,
                        quantity: quantity,
                      );

                      // 2. MOSTRAMOS EL SNACKBAR
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Agregaste $quantity ${widget.product.name} al pedido',
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );

                      // 3. VOLVEMOS AL MENÚ
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF81C784),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Agregar",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "S/${totalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
