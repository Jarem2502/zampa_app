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

  String _selectedOrderType = 'Llevar';
  TableModel? _selectedTable;
  String _selectedDocType = 'Boleta';

  List<TableModel> _availableTables = [];
  bool _isLoadingTables = false;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    setState(() => _isLoadingTables = true);
    final allTables = await TableService().getTables();

    if (mounted) {
      setState(() {
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
    super.dispose();
  }

  void _proceedToPayment() {
    if (_selectedOrderType == 'Local' && _selectedTable == null) {
      _showError('Por favor, selecciona una mesa para continuar.');
      return;
    }

    if (_nameController.text.trim().isEmpty ||
        _documentController.text.trim().isEmpty) {
      _showError('Por favor, completa tus datos para el comprobante.');
      return;
    }

    if (_selectedDocType == 'Boleta' && _documentController.text.length != 8) {
      _showError('El DNI debe tener exactamente 8 dígitos.');
      return;
    }

    if (_selectedDocType == 'Factura' &&
        _documentController.text.length != 11) {
      _showError('El RUC debe tener exactamente 11 dígitos.');
      return;
    }

    final extraData = {
      'total': widget.totalAmount,
      'order_type': _selectedOrderType == 'Local'
          ? 'En Mesa (${_selectedTable!.name})'
          : 'Para Llevar',
      'doc_type': _selectedDocType,
      'nombre': _nameController.text.trim(),
      'dni_ruc': _documentController.text.trim(),
      'metodo': 'Yape/Plin',
    };

    context.push('/pago-comprobante', extra: extraData);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: const Text(
          "Finalizar Pedido",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. TIPO DE PEDIDO ---
            const Text(
              "¿Dónde vas a disfrutarlo?",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildOrderTypeCard(
                  title: 'Para Llevar',
                  icon: Icons.shopping_bag_outlined,
                  isSelected: _selectedOrderType == 'Llevar',
                  onTap: () {
                    setState(() {
                      _selectedOrderType = 'Llevar';
                      _selectedTable = null;
                    });
                  },
                ),
                const SizedBox(width: 16),
                _buildOrderTypeCard(
                  title: 'En Local',
                  icon: Icons.restaurant,
                  isSelected: _selectedOrderType == 'Local',
                  onTap: () => setState(() => _selectedOrderType = 'Local'),
                ),
              ],
            ),

            // --- 2. SELECCIÓN DE MESA (Animado) ---
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _selectedOrderType == 'Local'
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    "Mesas Disponibles",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingTables)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    )
                  else if (_availableTables.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Lo sentimos, no hay mesas disponibles ahora.",
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _availableTables.map((table) {
                        bool isSel = _selectedTable?.id == table.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTable = table),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSel ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSel
                                    ? Colors.black
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.table_restaurant,
                                  color: isSel ? Colors.white : Colors.black54,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${table.name} (${table.capacity}p)",
                                  style: TextStyle(
                                    color: isSel
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // --- 3. DATOS DE COMPROBANTE ---
            const Text(
              "Datos de Facturación",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Toggle Boleta/Factura
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildDocTypeToggle(
                    'Boleta',
                    Icons.receipt_long,
                    _selectedDocType == 'Boleta',
                  ),
                  _buildDocTypeToggle(
                    'Factura',
                    Icons.request_quote,
                    _selectedDocType == 'Factura',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildInputField(
              controller: _documentController,
              label: _selectedDocType == 'Boleta'
                  ? "Número de DNI"
                  : "Número de RUC",
              icon: Icons.badge_outlined,
              kbType: TextInputType.number,
              maxLength: _selectedDocType == 'Boleta' ? 8 : 11,
            ),

            const SizedBox(height: 16),

            _buildInputField(
              controller: _nameController,
              label: _selectedDocType == 'Boleta'
                  ? "Nombre Completo"
                  : "Razón Social",
              icon: _selectedDocType == 'Boleta'
                  ? Icons.person_outline
                  : Icons.domain,
            ),

            const SizedBox(
              height: 100,
            ), // Espacio para que el scroll no quede tapado por el botón inferior
          ],
        ),
      ),

      // --- 4. BOTÓN INFERIOR FIJO ---
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _proceedToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                elevation: 5,
                shadowColor: Colors.black.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
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
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "S/${widget.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildOrderTypeCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.grey.shade200,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black54,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocTypeToggle(String text, IconData icon, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDocType = text;
            _documentController.clear();
            _nameController.clear();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.black : Colors.grey[600],
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.grey[600],
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
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.normal,
        ),
        counterText: '',
        prefixIcon: Icon(icon, color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
    );
  }
}
