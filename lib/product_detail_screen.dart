import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'zampa_data.dart';

// Si NO tienes el archivo aún, usa la clase Product que puse al final de este código.

class ProductDetailScreen extends StatefulWidget {
  // Recibimos el objeto Product (que nos mandaron desde el Menú)
  final Product product;

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
  Widget build(BuildContext context) {
    // Calculamos el total en tiempo real
    double totalPrice = widget.product.price * quantity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          
          // 1. ZONA SUPERIOR (Imagen + Botón Volver)
          Stack(
            children: [
              // Fondo gris o Imagen
              Container(
                height: 300,
                width: double.infinity,
                color: const Color(0xFFF5F5F5), // Gris muy suave
                child: Center(
                  child: Icon(
                    // Icono dinámico según categoría (solo visual)
                    widget.product.category == 'Bebidas' ? Icons.local_cafe : Icons.fastfood,
                    size: 100,
                    color: Colors.black26,
                  ),
                ),
              ),
              
              // Botón Volver (Flecha atrás)
              Positioned(
                top: 50,
                left: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      // --- CAMBIO GO_ROUTER ---
                      context.pop(); // Volver a la pantalla anterior
                    },
                  ),
                ),
              ),
            ],
          ),

          // 2. DETALLE DEL PRODUCTO (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y Precio
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

                  // Descripción
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

                  // Input de notas
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
                // Contador (- 1 +)
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
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

                // Botón Agregar
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Aquí iría la lógica para guardar en carrito real (Provider/Bloc/Riverpod)
                      // Por ahora solo mostramos un aviso visual
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Agregaste $quantity ${widget.product.name} al pedido'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      
                      // --- CAMBIO GO_ROUTER ---
                      context.pop(); // Volver al menú después de agregar
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
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "S/${totalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
