import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Importante para la navegación

class PaymentUploadScreen extends StatefulWidget {
  final double totalAmount;
  final int paymentMethod; // 1: Yape/Plin, 2: Transferencia
  final String clientName;

  const PaymentUploadScreen({
    super.key,
    required this.totalAmount,
    required this.paymentMethod,
    required this.clientName,
  });

  @override
  State<PaymentUploadScreen> createState() => _PaymentUploadScreenState();
}

class _PaymentUploadScreenState extends State<PaymentUploadScreen> {
  // Simulación de archivo seleccionado
  bool _isImageSelected = false;

  @override
  Widget build(BuildContext context) {
    bool isYape = widget.paymentMethod == 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(), // CAMBIO: GoRouter pop
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
            // 1. INFORMACIÓN DE PAGO (QR O CUENTA)
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
                    isYape ? "Escanea el QR o Yapea al:" : "Transfiere al número de cuenta:",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  
                  // NÚMERO DE TELÉFONO O CUENTA
                  Text(
                    isYape ? "987 654 321" : "BCP: 191-12345678-0-99",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isYape ? Colors.purple : Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  const Text(
                    "Titular: Zampa Café SAC",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  if (isYape) ...[
                    const SizedBox(height: 20),
                    Container(
                      height: 150, width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: const Center(
                        child: Icon(Icons.qr_code_scanner, size: 80, color: Colors.black26),
                      ),
                    ),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. MONTO A PAGAR
            const Text("Monto Total a Pagar", style: TextStyle(color: Colors.grey)),
            Text(
              "S/${widget.totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            // 3. SUBIR CAPTURA (EVIDENCIA)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Adjuntar Comprobante", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () {
                // Simulación de selección de imagen
                setState(() {
                  _isImageSelected = !_isImageSelected; 
                });
              },
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _isImageSelected ? Colors.green[50] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isImageSelected ? Colors.green : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: _isImageSelected
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green, size: 50),
                          SizedBox(height: 10),
                          Text("Captura Adjuntada", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, color: Colors.grey[600], size: 40),
                          const SizedBox(height: 10),
                          const Text("Subir captura de pantalla", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 40),

            // 4. BOTÓN FINALIZAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isImageSelected 
                  ? () => _showSuccessDialog(context)
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Por favor adjunta la captura del pago")),
                      );
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isImageSelected ? Colors.black : Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "Enviar Pedido",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // DIÁLOGO DE ÉXITO
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text("¡Pedido Enviado!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                "Gracias ${widget.clientName}, hemos recibido tu comprobante. Validaremos tu pago en breve.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // --- CAMBIO GO_ROUTER ---
                  // Regresamos al menú principal limpiando toda la pila
                  context.go('/menu');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81C784),
                  shape: const StadiumBorder(),
                ),
                child: const Text("Volver al Menú", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}