import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        centerTitle: true,
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
                    leading: CircleAvatar(
                      backgroundColor: prod.isPromo
                          ? Colors.red[50]
                          : Colors.grey[200],
                      backgroundImage: prod.imageUrl != null
                          ? NetworkImage(prod.imageUrl!)
                          : null,
                      child: prod.imageUrl == null
                          ? Icon(
                              prod.isPromo ? Icons.local_offer : Icons.fastfood,
                              color: prod.isPromo ? Colors.red : Colors.grey,
                            )
                          : null,
                    ),
                    title: Text(
                      prod.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      prod.isPromo
                          ? "Antes S/ ${prod.price.toStringAsFixed(2)} | Ahora S/ ${prod.promoPrice.toStringAsFixed(2)}"
                          : "Precio: S/ ${prod.price.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: prod.isPromo ? Colors.red : Colors.grey,
                        fontWeight: prod.isPromo
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Crear Oferta para ${prod.name}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Precio Original: S/ ${prod.price.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Nuevo Precio Oferta",
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
                          content: Text("Ingresa un precio menor al original"),
                        ),
                      );
                      return;
                    }

                    context.pop(); // Cerramos el dialog

                    // Mostramos indicador de carga
                    setState(() => _isLoading = true);

                    // Llamamos a la API real
                    bool success = await _productService.updateProductPromo(
                      prod.id,
                      true,
                      newPrice,
                    );

                    if (success) {
                      await _loadProducts(); // Recargamos de la BD
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("¡Oferta aplicada a ${prod.name}!"),
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
                    "Aplicar Descuento",
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
        );
      },
    );
  }

  Future<void> _removeOffer(ProductModel prod) async {
    setState(() => _isLoading = true);
    // Llamamos a la API enviando isPromo = false
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
