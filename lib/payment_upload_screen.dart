import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🔥 Importante para leer el ID del usuario
import '../services/order_service.dart';
import '../providers/cart_provider.dart';

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
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _pickedFile = image;
      });
    }
  }

  Future<void> _handleSendOrder() async {
    if (_pickedFile == null) return;

    setState(() => _isSending = true);

    // 1. LEEMOS LOS BYTES DE LA IMAGEN
    final imageBytes = await _pickedFile!.readAsBytes();

    // 🔥 2. OBTENEMOS EL ID REAL DEL USUARIO LOGUEADO
    final prefs = await SharedPreferences.getInstance();
    // Intenta buscar 'user_id' o 'id'. Si por alguna razón está vacío, usa '1' como respaldo para que no explote.
    final dynamic savedId = prefs.get('user_id') ?? prefs.get('id');
    final String realUserId = savedId != null ? savedId.toString() : '1';

    // 3. PREPARAMOS LA DATA CON EL ID DINÁMICO
    final orderData = {
      'user_id': realUserId, // Ahora usa el ID real del teléfono/navegador
      'total': widget.totalAmount,
      'payment_method': widget.paymentMethod,
      'order_type': widget.extraData['tipo_pedido'],
      'client_name': widget.clientName,
      'dni': widget.extraData['dni'],
      'phone': widget.extraData['telefono'],
      'products': widget.extraData['productos'],
    };

    // 4. ENVIAMOS AL SERVICIO
    bool success = await _orderService.sendOrder(
      orderData: orderData,
      imagePath: _pickedFile!.path,
      imageBytes: imageBytes,
    );

    setState(() => _isSending = false);

    if (success) {
      context.read<CartProvider>().clearCart();
      _showSuccessDialog(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Error al enviar el pedido. Verifica tu conexión con Hostinger.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isYape = widget.paymentMethod == 'yape' || widget.paymentMethod == '1';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Realizar Pago",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isYape ? Colors.purple[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isYape ? Colors.purple.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isYape ? Icons.qr_code_2 : Icons.account_balance,
                    size: 50,
                    color: isYape ? Colors.purple : Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isYape
                        ? "Escanea el QR o Yapea al:"
                        : "Transfiere al número de cuenta:",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isYape ? "987 654 321" : "BCP: 191-12345678-0-99",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isYape ? Colors.purple : Colors.blue[900],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Monto Total a Pagar",
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              "S/${widget.totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _isSending ? null : _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _pickedFile != null
                      ? Colors.green[50]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _pickedFile != null
                        ? Colors.green
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: _pickedFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          _pickedFile!.path,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            color: Colors.grey[600],
                            size: 40,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Subir captura del pago",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (_pickedFile == null || _isSending)
                    ? null
                    : _handleSendOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pickedFile != null
                      ? Colors.black
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Enviar Pedido",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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
              "Gracias ${widget.clientName}, hemos recibido tu comprobante.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/menu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF81C784),
                shape: const StadiumBorder(),
              ),
              child: const Text(
                "Volver al Menú",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
