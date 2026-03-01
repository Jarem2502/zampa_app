import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/table_model.dart';
import '../services/table_service.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;

  const CheckoutScreen({super.key, required this.totalAmount});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _documentController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedOrderType = 'Llevar';
  TableModel? _selectedTable; // 🔥 Ahora guardamos el objeto Mesa completo
  String _selectedDocType = 'Boleta';

  // 🔥 Variables para las mesas reales de BD
  List<TableModel> _availableTables = [];
  bool _isLoadingTables = false;

  @override
  void initState() {
    super.initState();
    _loadTables(); // Cargamos las mesas al abrir la pantalla
  }

  // Descarga las mesas y filtra solo las disponibles
  Future<void> _loadTables() async {
    setState(() => _isLoadingTables = true);
    final allTables = await TableService().getTables();

    if (mounted) {
      setState(() {
        // Filtramos solo las que dicen "disponible" (ignoramos mayúsculas/minúsculas)
        _availableTables = allTables
            .where((t) => t.status.toLowerCase() == 'disponible')
            .toList();
        _isLoadingTables = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _documentController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    if (_selectedOrderType == 'Local' && _selectedTable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una mesa')),
      );
      return;
    }

    if (_nameController.text.trim().isEmpty ||
        _documentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa tus datos')),
      );
      return;
    }

    if (_selectedDocType == 'Boleta' && _documentController.text.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El DNI debe tener 8 dígitos')),
      );
      return;
    }

    if (_selectedDocType == 'Factura' &&
        _documentController.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El RUC debe tener 11 dígitos')),
      );
      return;
    }

    final extraData = {
      'total': widget.totalAmount,
      // 🔥 Ahora enviamos el nombre real de la mesa (ej: "Mesa 1")
      'order_type': _selectedOrderType == 'Local'
          ? 'En Mesa (${_selectedTable!.name})'
          : 'Para Llevar',
      'doc_type': _selectedDocType,
      'nombre': _nameController.text.trim(),
      'dni_ruc': _documentController.text.trim(),
      'phone': _phoneController.text.trim(),
      'metodo': 'Yape/Plin',
    };

    context.push('/pago-comprobante', extra: extraData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Finalizar Pedido",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¿Dónde vas a comer?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildToggleBtn(
                  'Llevar',
                  Icons.shopping_bag_outlined,
                  _selectedOrderType == 'Llevar',
                  () {
                    setState(() {
                      _selectedOrderType = 'Llevar';
                      _selectedTable = null;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _buildToggleBtn(
                  'Local',
                  Icons.restaurant,
                  _selectedOrderType == 'Local',
                  () {
                    setState(() => _selectedOrderType = 'Local');
                  },
                ),
              ],
            ),

            // --- DESPLEGABLE DE MESAS DINÁMICO ---
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _selectedOrderType == 'Local'
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Mesas Disponibles:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),

                  // 🔥 Lógica de carga de mesas
                  if (_isLoadingTables)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    )
                  else if (_availableTables.isEmpty)
                    const Text(
                      "No hay mesas disponibles en este momento.",
                      style: TextStyle(color: Colors.red),
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableTables.map((table) {
                        bool isSel = _selectedTable?.id == table.id;
                        return ChoiceChip(
                          label: Text(
                            "${table.name} (Max ${table.capacity}p)", // Muestra el nombre y capacidad
                            style: TextStyle(
                              color: isSel ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: Colors.black,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onSelected: (val) =>
                              setState(() => _selectedTable = table),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            const Text(
              "Tipo de comprobante",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildToggleBtn(
                  'Boleta',
                  Icons.receipt_long,
                  _selectedDocType == 'Boleta',
                  () {
                    setState(() {
                      _selectedDocType = 'Boleta';
                      _documentController.clear();
                      _nameController.clear();
                    });
                  },
                ),
                const SizedBox(width: 12),
                _buildToggleBtn(
                  'Factura',
                  Icons.request_quote,
                  _selectedDocType == 'Factura',
                  () {
                    setState(() {
                      _selectedDocType = 'Factura';
                      _documentController.clear();
                      _nameController.clear();
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 25),

            Text(
              _selectedDocType == 'Boleta'
                  ? "Datos Personales"
                  : "Datos de la Empresa",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            _buildInputField(
              controller: _documentController,
              label: _selectedDocType == 'Boleta'
                  ? "Número de DNI"
                  : "Número de RUC",
              icon: Icons.badge_outlined,
              kbType: TextInputType.number,
              maxLength: _selectedDocType == 'Boleta' ? 8 : 11,
            ),
            const SizedBox(height: 15),

            _buildInputField(
              controller: _nameController,
              label: _selectedDocType == 'Boleta'
                  ? "Nombre Completo"
                  : "Razón Social",
              icon: _selectedDocType == 'Boleta'
                  ? Icons.person_outline
                  : Icons.domain,
            ),
            const SizedBox(height: 15),

            _buildInputField(
              controller: _phoneController,
              label: "Teléfono (Opcional)",
              icon: Icons.phone_android,
              kbType: TextInputType.phone,
              maxLength: 9,
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _proceedToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81C784),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Ir a Pagar",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "S/${widget.totalAmount.toStringAsFixed(2)}",
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleBtn(
    String text,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.grey.shade300,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black54,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType kbType = TextInputType.text,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: kbType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
