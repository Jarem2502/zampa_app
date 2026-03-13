import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';

const Color zampaGreen = Color(0xFF1A9956);
const Color zampaRed = Color(0xFFE53935);

class AdminOfferManagerScreen extends StatefulWidget {
  const AdminOfferManagerScreen({super.key});

  @override
  State<AdminOfferManagerScreen> createState() =>
      _AdminOfferManagerScreenState();
}

class _AdminOfferManagerScreenState extends State<AdminOfferManagerScreen> {
  // 🔥 ESTADO LOCAL PARA LOS SWITCHES
  // Esto guarda temporalmente si encendiste/apagaste una oferta en esta sesión
  final Map<int, bool> _localPromoState = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  // 🔥 FUNCIÓN PARA ABRIR CALENDARIO
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: zampaGreen, // Colores Zampa
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // Formateamos la fecha a YYYY-MM-DD
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  void _showCreateOfferModal(BuildContext context, ProductModel product) {
    final TextEditingController motivoCtrl = TextEditingController();
    final TextEditingController inicioCtrl = TextEditingController();
    final TextEditingController finCtrl = TextEditingController();

    // Controladores para la matemática inteligente
    final TextEditingController porcentajeCtrl = TextEditingController();
    final TextEditingController precioFinalCtrl = TextEditingController(
      text: product.price.toStringAsFixed(2),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
                              "Crear Oferta: ${product.name}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Precio Original: S/ ${product.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                          // Si cerramos, apagamos el switch visualmente
                          setState(() => _localPromoState[product.id] = false);
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: motivoCtrl,
                    decoration: InputDecoration(
                      labelText: "Motivo (Ej. Día de la Madre)",
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
                        // 🔥 CAMPO FECHA INICIO FUNCIONAL
                        child: GestureDetector(
                          onTap: () => _selectDate(ctx, inicioCtrl),
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
                        // 🔥 CAMPO FECHA FIN FUNCIONAL
                        child: GestureDetector(
                          onTap: () => _selectDate(ctx, finCtrl),
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

                  // 🔥 CALCULADORA INTELIGENTE DE DESCUENTOS
                  const Text(
                    "Configura el descuento:",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Input Porcentaje
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
                            // Al escribir porcentaje, calculamos precio final
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
                      // Input Precio Final
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
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: zampaGreen,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            // Al escribir precio final, calculamos porcentaje
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

                  // Botón Publicar
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // 1. Validaciones básicas
                        if (inicioCtrl.text.isEmpty || finCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Selecciona las fechas por favor"),
                            ),
                          );
                          return;
                        }

                        // 2. Encendemos el switch visualmente
                        setState(() {
                          _localPromoState[product.id] = true;
                        });

                        // 3. Cerramos modal y avisamos éxito
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "¡Promoción activada a S/${precioFinalCtrl.text}!",
                            ),
                            backgroundColor: zampaGreen,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.4),
                      ),
                      child: const Text(
                        "Publicar Promoción",
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
      // Si el modal se cierra tocando afuera (sin guardar), apagamos el switch si estaba apagado antes
      if (_localPromoState[product.id] == true && !mounted) return;
      // Si no confirmaron, reseteamos el estado visual
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

                // 🔥 ESTADO INTELIGENTE: Revisa si se cambió en esta sesión, si no, usa el de BD
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
                    ), // Borde verde si está activo
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
                      // Miniatura del producto
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
                      // Datos
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
                              const Text(
                                "OFERTA ACTIVA",
                                style: TextStyle(
                                  color: zampaGreen,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ), // Texto Verde
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
                      // 🔥 SWITCH INTERACTIVO
                      Switch(
                        value: isOfferActive,
                        activeColor: zampaGreen, // Cambiado a verde oficial
                        activeTrackColor: zampaGreen.withOpacity(0.3),
                        onChanged: (val) {
                          if (val) {
                            // Cambia el estado temporal para encender el switch, y abre modal
                            setState(() => _localPromoState[product.id] = true);
                            _showCreateOfferModal(context, product);
                          } else {
                            // Apaga la oferta
                            setState(
                              () => _localPromoState[product.id] = false,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Oferta desactivada"),
                                backgroundColor: Colors.grey,
                              ),
                            );
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
