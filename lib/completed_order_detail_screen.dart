import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Importante para la navegación

class CompletedOrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const CompletedOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(), // CAMBIO: Usamos context.pop()
        ),
        title: const Text(
          "Detalles de Compra", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CABECERA: ESTADO Y FECHA ---
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (order['statusColor'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order['status'],
                      style: TextStyle(
                        color: order['statusColor'], 
                        fontWeight: FontWeight.bold, 
                        fontSize: 14
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(order['date'], style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text(
                    "Pedido ${order['id']}", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            // --- SECCIÓN PRODUCTOS ---
            const Text(
              "Resumen de Productos", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                order['items'], 
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),

            const SizedBox(height: 25),

            // --- TOTAL PAGADO ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Pagado", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
                ),
                Text(
                  "S/${order['total'].toStringAsFixed(2)}", 
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 22, 
                    color: Colors.green
                  )
                ),
              ],
            ),

            const Spacer(),

            // --- BOTÓN VOLVER A PEDIR (CTA) ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  // LÓGICA DE RE-COMPRA
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("¡Productos agregados al carrito!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // --- CAMBIO GO_ROUTER ---
                  // Navegamos directamente al carrito para que el usuario proceda
                  context.push('/carrito');
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  "Volver a Pedir", 
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // BOTÓN DE AYUDA
            Center(
              child: TextButton(
                onPressed: () {
                  // Podríamos navegar al Chatbot aquí
                  context.push('/chatbot');
                },
                child: const Text(
                  "¿Necesitas ayuda con este pedido?", 
                  style: TextStyle(color: Colors.black54, decoration: TextDecoration.underline)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}