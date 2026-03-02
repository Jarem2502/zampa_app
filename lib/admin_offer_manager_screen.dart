import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'services/product_service.dart';
import 'models/product_model.dart';

class AdminOfferManagerScreen extends StatefulWidget {
  const AdminOfferManagerScreen({super.key});

  @override
  State<AdminOfferManagerScreen> createState() =>
      _AdminOfferManagerScreenState();
}

class _AdminOfferManagerScreenState extends State<AdminOfferManagerScreen> {
  final ProductService _productService = ProductService();
  bool _isLoading = true;
  List<ProductModel> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final fetched = await _productService.getProducts();
    if (mounted) {
      setState(() {
        _products = fetched;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Gestor de Ofertas",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final prod = _products[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      prod.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Precio base: S/ ${prod.price.toStringAsFixed(2)}",
                        ),
                        if (prod.isPromo) ...[
                          const SizedBox(height: 4),
                          Text(
                            "🎉 ${prod.promoName ?? 'Oferta Especial'}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "S/ ${prod.promoPrice.toStringAsFixed(2)} (Hasta el ${prod.promoEnd ?? 'Aviso'})",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Switch(
                      value: prod.isPromo,
                      activeColor: Colors.red,
                      onChanged: (val) {
                        if (val) {
                          _showOfferDialog(context, prod);
                        } else {
                          _removeOffer(prod);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showOfferDialog(BuildContext context, ProductModel prod) {
    final priceController = TextEditingController();
    final nameController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 7));

    // Función auxiliar para aplicar descuentos rápidos
    void applyDiscount(int percent, StateSetter setModalState) {
      double newPrice = prod.price - (prod.price * (percent / 100));
      setModalState(() {
        priceController.text = newPrice.toStringAsFixed(2);
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Crear Oferta: ${prod.name}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Precio Original: S/ ${prod.price.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Motivo de la oferta
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Motivo (Ej. Día de la Madre)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Fechas
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null)
                              setModalState(() => startDate = picked);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Inicio",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              DateFormat('yyyy-MM-dd').format(startDate),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: startDate,
                              lastDate: DateTime(2030),
                            );
                            if (picked != null)
                              setModalState(() => endDate = picked);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Fin",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              DateFormat('yyyy-MM-dd').format(endDate),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botones de descuento rápido
                  const Text(
                    "Descuento rápido:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => applyDiscount(10, setModalState),
                        child: const Text("-10%"),
                      ),
                      ElevatedButton(
                        onPressed: () => applyDiscount(20, setModalState),
                        child: const Text("-20%"),
                      ),
                      ElevatedButton(
                        onPressed: () => applyDiscount(50, setModalState),
                        child: const Text("-50%"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Precio final manual
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: "Precio Final Oferta (S/)",
                      prefixIcon: const Icon(
                        Icons.monetization_on,
                        color: Colors.green,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón Guardar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        double newPrice =
                            double.tryParse(priceController.text) ?? 0.0;
                        if (newPrice <= 0 || newPrice >= prod.price) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Ingresa un precio menor al original",
                              ),
                            ),
                          );
                          return;
                        }

                        context.pop();
                        setState(() => _isLoading = true);

                        bool success = await _productService.updateProductPromo(
                          prod.id,
                          true,
                          newPrice,
                          name: nameController.text.trim().isEmpty
                              ? 'Oferta Especial'
                              : nameController.text.trim(),
                          start: DateFormat('yyyy-MM-dd').format(startDate),
                          end: DateFormat('yyyy-MM-dd').format(endDate),
                        );

                        if (success) {
                          await _loadProducts();
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "¡Oferta aplicada a ${prod.name}!",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                        } else {
                          setState(() => _isLoading = false);
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Error al aplicar oferta"),
                                backgroundColor: Colors.red,
                              ),
                            );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Publicar Promoción",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _removeOffer(ProductModel prod) async {
    setState(() => _isLoading = true);
    bool success = await _productService.updateProductPromo(
      prod.id,
      false,
      0.0,
    );
    if (success) {
      await _loadProducts();
    } else {
      setState(() => _isLoading = false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al quitar oferta"),
            backgroundColor: Colors.red,
          ),
        );
    }
  }
}
