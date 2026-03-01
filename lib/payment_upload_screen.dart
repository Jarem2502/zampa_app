import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class PaymentUploadScreen extends StatefulWidget {
  final double totalAmount;
  final String paymentMethod;
  final String clientName;
  final Map<String, dynamic> extraData;

  const PaymentUploadScreen({
    super.key,
    required this.totalAmount,
    required this.paymentMethod,
    required this.clientName,
    required this.extraData,
  });

  @override
  State<PaymentUploadScreen> createState() => _PaymentUploadScreenState();
}

class _PaymentUploadScreenState extends State<PaymentUploadScreen> {
  XFile? _pickedFile;
  bool _isSending = false;
  final _orderService = OrderService();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Comprimimos un poco para no saturar Hostinger
    );

    if (image != null) {
      setState(() {
        _pickedFile = image;
      });
    }
  }

  Future<void> _sendOrder() async {
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, sube la captura de tu pago")),
      );
      return;
    }

    setState(() => _isSending = true);

    // 1. Obtenemos los proveedores (Carrito y Usuario)
    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();

    // 2. Transformamos el carrito en un JSON que Laravel entienda
    final productsJson = cart.items
        .map(
          (item) => {
            'product_id': item.product.id,
            'name': item.product.name,
            'quantity': item.quantity,
            'price': item.product.isPromo
                ? item.product.promoPrice
                : item.product.price,
          },
        )
        .toList();

    // 3. Juntamos toda la información
    final orderData = {
      'user_id': auth.user?.id ?? 0, // ID del usuario real
      'total': widget.totalAmount,
      'payment_method': widget.extraData['metodo'],
      'order_type': widget.extraData['order_type'],
      'client_name': widget.extraData['nombre'],
      'dni': widget.extraData['dni_ruc'],
      'phone': widget.extraData['phone'],
      'products': jsonEncode(productsJson), // Convertimos la lista a texto
    };

    // 4. Leemos la imagen como bytes
    final bytes = await _pickedFile!.readAsBytes();

    // 5. Enviamos todo a Hostinger
    bool success = await _orderService.sendOrder(
      orderData: orderData,
      imagePath: _pickedFile!.path,
      imageBytes: bytes,
    );

    setState(() => _isSending = false);

    if (success && mounted) {
      cart.clearCart(); // ¡Vaciamos el carrito porque ya compró!
      _showSuccessDialog(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Hubo un error al enviar el pedido. Intenta nuevamente.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Comprobante",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Ya casi terminamos",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Por favor, transfiere el total de S/${widget.totalAmount.toStringAsFixed(2)} a nuestro número Yape o Plin y sube la captura de pantalla.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
            const SizedBox(height: 30),

            // Número a yapear (Simulado)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.deepPurple[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: const Column(
                children: [
                  Text(
                    "Número Yape / Plin",
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "987 654 321",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Text(
                    "A nombre de: Zampa Café",
                    style: TextStyle(fontSize: 12, color: Colors.deepPurple),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Área para subir la imagen
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: _pickedFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        // En web a veces Image.network funciona mejor para archivos locales en memoria
                        child: Image.network(
                          _pickedFile!.path,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Toca para subir captura",
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 40),

            // Botón de Confirmación
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Confirmar Pedido",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              "¡Pedido Enviado!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Gracias ${widget.clientName}, tu comprobante será validado por caja en breve.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop(); // Cierra el diálogo
                  context.go('/menu'); // Vuelve al inicio limpio
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81C784),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Volver al Menú",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
