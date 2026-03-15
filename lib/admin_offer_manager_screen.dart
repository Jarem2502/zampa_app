import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

const Color zampaGreen = Color(0xFF1A9956);
const Color zampaRed = Color(0xFFE53935);

class AdminOfferManagerScreen extends StatefulWidget {
  const AdminOfferManagerScreen({super.key});

  @override
  State<AdminOfferManagerScreen> createState() =>
      _AdminOfferManagerScreenState();
}

class _AdminOfferManagerScreenState extends State<AdminOfferManagerScreen> {
  final Map<int, bool> _localPromoState = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  // 🔥 Función mejorada: Ahora acepta una "Fecha Mínima" (minDate)
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller, {
    DateTime? minDate,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Si nos pasan una fecha mínima, la usamos. Si no, usamos hoy.
    DateTime first = minDate ?? today;

    // Por seguridad, la fecha mínima nunca puede ser antes de hoy en este contexto
    if (first.isBefore(today)) {
      first = today;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: first,
      firstDate: first, // Bloquea todos los días anteriores a esta fecha
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: zampaGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  void _showCreateOfferModal(BuildContext context, ProductModel product) {
    final TextEditingController motivoCtrl = TextEditingController();
    final TextEditingController inicioCtrl = TextEditingController();
    final TextEditingController finCtrl = TextEditingController();
    final TextEditingController porcentajeCtrl = TextEditingController();
    final TextEditingController precioFinalCtrl = TextEditingController(
      text: product.price.toStringAsFixed(2),
    );

    if (product.isPromo) {
      motivoCtrl.text = product.promoName ?? '';
      inicioCtrl.text = product.promoStart ?? '';
      finCtrl.text = product.promoEnd ?? '';
      precioFinalCtrl.text = product.promoPrice.toStringAsFixed(2);
      porcentajeCtrl.text =
          (((product.price - product.promoPrice) / product.price) * 100)
              .toStringAsFixed(0);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: !_isSaving,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Oferta: ${product.name}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Precio Base: S/ ${product.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_isSaving)
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.black87,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            setState(
                              () => _localPromoState[product.id] = false,
                            );
                            Navigator.pop(ctx);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: motivoCtrl,
                    decoration: InputDecoration(
                      labelText: "Motivo (Ej. Promo de Verano)",
                      prefixIcon: const Icon(
                        Icons.celebration,
                        color: zampaRed,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(
                            ctx,
                            inicioCtrl,
                          ), // Fecha Inicio (Desde hoy)
                          child: AbsorbPointer(
                            child: TextField(
                              controller: inicioCtrl,
                              decoration: InputDecoration(
                                labelText: "Inicio",
                                hintText: "YYYY-MM-DD",
                                prefixIcon: const Icon(
                                  Icons.calendar_today,
                                  color: Colors.black54,
                                  size: 18,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // 🔥 LÓGICA DE BLOQUEO: Calculamos la fecha mínima basada en la fecha de inicio
                            DateTime? minDate;
                            if (inicioCtrl.text.isNotEmpty) {
                              minDate = DateTime.tryParse(inicioCtrl.text);
                            }
                            _selectDate(ctx, finCtrl, minDate: minDate);
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: finCtrl,
                              decoration: InputDecoration(
                                labelText: "Fin",
                                hintText: "YYYY-MM-DD",
                                prefixIcon: const Icon(
                                  Icons.event_busy,
                                  color: Colors.black54,
                                  size: 18,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Configura el descuento:",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: porcentajeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "% Descuento",
                            prefixIcon: const Icon(
                              Icons.percent,
                              color: zampaRed,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) {
                            double percent = double.tryParse(val) ?? 0;
                            if (percent >= 0 && percent <= 100) {
                              double finalPrice =
                                  product.price * (1 - (percent / 100));
                              precioFinalCtrl.text = finalPrice.toStringAsFixed(
                                2,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.arrow_forward, color: Colors.grey),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: precioFinalCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Precio Oferta (S/)",
                            prefixIcon: const Icon(
                              Icons.attach_money,
                              color: zampaGreen,
                            ),
                            filled: true,
                            fillColor: zampaGreen.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: zampaGreen,
                                width: 1,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            double finalPrice =
                                double.tryParse(val) ?? product.price;
                            if (finalPrice <= product.price &&
                                finalPrice >= 0) {
                              double percent =
                                  ((product.price - finalPrice) /
                                      product.price) *
                                  100;
                              porcentajeCtrl.text = percent.toStringAsFixed(0);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (inicioCtrl.text.isEmpty ||
                                  finCtrl.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Selecciona las fechas por favor",
                                    ),
                                  ),
                                );
                                return;
                              }

                              setModalState(() => _isSaving = true);

                              double finalPrice =
                                  double.tryParse(precioFinalCtrl.text) ??
                                  product.price;

                              bool success = await ProductService()
                                  .updateProductPromo(
                                    product.id,
                                    true,
                                    finalPrice,
                                    name: motivoCtrl.text,
                                    start: inicioCtrl.text,
                                    end: finCtrl.text,
                                  );

                              setModalState(() => _isSaving = false);

                              if (success) {
                                setState(
                                  () => _localPromoState[product.id] = true,
                                );
                                if (ctx.mounted) Navigator.pop(ctx);

                                context.read<ProductProvider>().fetchProducts();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "¡Promoción GUARDADA a S/${finalPrice.toStringAsFixed(2)}!",
                                    ),
                                    backgroundColor: zampaGreen,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Error al guardar la promoción",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Guardar",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      if (_localPromoState[product.id] == true && !mounted) return;
      if (_localPromoState[product.id] != true) {
        setState(() => _localPromoState[product.id] = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
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
          "Gestor de Ofertas",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        ),
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: zampaGreen))
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: productProvider.products.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final product = productProvider.products[index];
                bool isOfferActive =
                    _localPromoState[product.id] ?? product.isPromo;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOfferActive
                          ? zampaGreen.withOpacity(0.5)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl ??
                              'https://ui-avatars.com/api/?name=Zampa',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.fastfood,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (isOfferActive) ...[
                              Text(
                                "Precio Base: S/ ${product.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "OFERTA: S/ ${product.promoPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: zampaGreen,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ] else
                              Text(
                                "Precio base: S/ ${product.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isOfferActive,
                        activeColor: zampaGreen,
                        activeTrackColor: zampaGreen.withOpacity(0.3),
                        onChanged: _isSaving
                            ? null
                            : (val) async {
                                if (val) {
                                  setState(
                                    () => _localPromoState[product.id] = true,
                                  );
                                  _showCreateOfferModal(context, product);
                                } else {
                                  setState(() {
                                    _isSaving = true;
                                    _localPromoState[product.id] = false;
                                  });

                                  bool success = await ProductService()
                                      .updateProductPromo(product.id, false, 0);

                                  setState(() => _isSaving = false);

                                  if (success) {
                                    context
                                        .read<ProductProvider>()
                                        .fetchProducts();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Oferta desactivada"),
                                        backgroundColor: Colors.grey,
                                      ),
                                    );
                                  }
                                }
                              },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
