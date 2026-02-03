import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Importante para la navegación

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;

  const CheckoutScreen({super.key, required this.totalAmount});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Controladores de texto
  final _nameController = TextEditingController();
  final _dniController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Selección de opciones (Básico: 1 o 2)
  int _selectedPaymentMethod = 1; // 1: Yape/Plin, 2: Transferencia
  int _selectedOrderType = 1;     // 1: Tienda, 2: Llevar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(), // CAMBIO: Usamos context.pop()
        ),
        title: const Text(
          "Confirmar Datos",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. RESUMEN DEL MONTO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), 
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total a Pagar:", style: TextStyle(fontSize: 16)),
                  Text(
                    "S/${widget.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 2. TIPO DE PEDIDO (Uso de Row/Column básico)
            const Text("¿Cómo deseas tu pedido?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildOrderTypeCard(1, "En tienda", Icons.store_mall_directory)),
                const SizedBox(width: 12),
                Expanded(child: _buildOrderTypeCard(2, "Para llevar", Icons.shopping_bag)),
              ],
            ),

            const SizedBox(height: 30),

            // 3. FORMULARIO
            const Text("Tus Datos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildTextField(controller: _nameController, label: "Nombre", icon: Icons.person_outline),
            const SizedBox(height: 15),
            _buildTextField(controller: _dniController, label: "DNI", icon: Icons.badge_outlined, kbType: TextInputType.number),
            const SizedBox(height: 15),
            _buildTextField(controller: _phoneController, label: "Celular", icon: Icons.phone_android, kbType: TextInputType.phone),
            
            const SizedBox(height: 30),

            // 4. MÉTODOS DE PAGO
            const Text("Método de Pago", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildPaymentOption(1, "Yape / Plin", Icons.qr_code_2, Colors.purple),
            const SizedBox(height: 10),
            _buildPaymentOption(2, "Transferencia", Icons.account_balance, Colors.blue),
            
            const SizedBox(height: 40),

            // 5. BOTÓN CONTINUAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isEmpty || _dniController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Completa tus datos")),
                    );
                    return;
                  }

                  // --- NAVEGACIÓN CON GO_ROUTER ---
                  // Pasamos los datos necesarios a la pantalla de subir comprobante
                  context.push('/pago-comprobante', extra: {
                    'total': widget.totalAmount,
                    'metodo': _selectedPaymentMethod,
                    'nombre': _nameController.text,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "Continuar al Pago",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET AUXILIAR: TARJETAS DE TIPO DE PEDIDO
  Widget _buildOrderTypeCard(int value, String title, IconData icon) {
    bool isSel = _selectedOrderType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedOrderType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSel ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSel ? Colors.black : Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSel ? Colors.white : Colors.black54),
            Text(title, style: TextStyle(color: isSel ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // WIDGET AUXILIAR: INPUTS
  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType kbType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: kbType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black12)),
      ),
    );
  }

  // WIDGET AUXILIAR: OPCIONES DE PAGO
  Widget _buildPaymentOption(int value, String title, IconData icon, Color color) {
    bool isSel = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSel ? Colors.black : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (isSel) const Icon(Icons.check_circle, color: Colors.black),
          ],
        ),
      ),
    );
  }
}