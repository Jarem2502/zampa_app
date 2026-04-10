import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'providers/product_provider.dart';
import 'models/product_model.dart';
import 'services/product_service.dart';

const Color zampaRed = Color(0xFFDB0212);
const Color zampaYellow = Color(0xFFF5D509);
const Color zampaGreen = Color(0xFF32903A);
const Color zampaWhite = Color(0xFFD1D1D1);
const Color zampaBlack = Color(0xFF010201);

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final Map<int, bool> _availabilityState = {};
  bool _isSaving = false;

  // 🔥 Las categorías de tu BD (Omitimos el "Todos" porque un producto real debe tener una categoría específica)
  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Hamburguesas'},
    {'id': 2, 'name': 'Salchipapas'},
    {'id': 3, 'name': 'Sándwiches'},
    {'id': 4, 'name': 'Enchiladas'},
    {'id': 5, 'name': 'Especiales'},
    {'id': 6, 'name': 'Bebidas Frías'},
    {'id': 7, 'name': 'Cafés'},
    {'id': 8, 'name': 'Jugos'},
    {'id': 11, 'name': 'Calientes'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  void _showImageSource(BuildContext context, Function(XFile) onImagePicked) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: zampaGreen),
              title: const Text(
                'Tomar Foto',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                  imageQuality: 70,
                );
                if (picked != null) onImagePicked(picked);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: zampaGreen,
              ),
              title: const Text(
                'Elegir de Galería',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 70,
                );
                if (picked != null) onImagePicked(picked);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProductModal(BuildContext context, {ProductModel? product}) {
    final TextEditingController nameCtrl = TextEditingController(
      text: product?.name ?? '',
    );
    final TextEditingController priceCtrl = TextEditingController(
      text: product?.price.toStringAsFixed(2) ?? '',
    );
    final TextEditingController descCtrl = TextEditingController(
      text: product?.description ?? '',
    ); // 🔥 NUEVO: Descripción
    int selectedCategoryId =
        product?.categoryId ??
        1; // 🔥 NUEVO: Categoría por defecto (Hamburguesas)

    XFile? selectedImage;
    Uint8List? imageBytes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: !_isSaving,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height:
                  MediaQuery.of(context).size.height *
                  0.85, // Ocupa un poco más de pantalla para los nuevos campos
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product == null ? "Nuevo Producto" : "Editar Producto",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: zampaBlack,
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
                              color: zampaBlack,
                              size: 20,
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Todo el formulario dentro de un scroll por si el teclado lo tapa
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () =>
                                  _showImageSource(context, (picked) async {
                                    final bytes = await picked.readAsBytes();
                                    setModalState(() {
                                      selectedImage = picked;
                                      imageBytes = bytes;
                                    });
                                  }),
                              child: Container(
                                height: 140,
                                width: 140,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: zampaWhite,
                                    width: 2,
                                  ),
                                  image: imageBytes != null
                                      ? DecorationImage(
                                          image: MemoryImage(imageBytes!),
                                          fit: BoxFit.cover,
                                        )
                                      : (product?.imageUrl != null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                  product!.imageUrl!,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : null),
                                ),
                                child:
                                    imageBytes == null &&
                                        product?.imageUrl == null
                                    ? const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo_rounded,
                                            color: Colors.grey,
                                            size: 40,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "Añadir Foto",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                            color: zampaBlack,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            "Nombre del Producto",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: zampaBlack,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: nameCtrl,
                            decoration: InputDecoration(
                              hintText: "Ej. Hamburguesa Royal",
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: zampaGreen,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Precio Base (S/)",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: zampaBlack,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: priceCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          Icons.attach_money,
                                          color: zampaGreen,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: const BorderSide(
                                            color: zampaGreen,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Categoría",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: zampaBlack,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<int>(
                                      value: selectedCategoryId,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                      ),
                                      items: _categories.map((cat) {
                                        return DropdownMenuItem<int>(
                                          value: cat['id'],
                                          child: Text(
                                            cat['name'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null)
                                          setModalState(
                                            () => selectedCategoryId = val,
                                          );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            "Descripción",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: zampaBlack,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: descCtrl,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText:
                                  "Ej. Deliciosa carne artesanal con queso derretido...",
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: zampaGreen,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // BOTÓN GUARDAR (Fijo en la parte inferior)
                  Container(
                    width: double.infinity,
                    height: 55,
                    margin: const EdgeInsets.only(bottom: 24, top: 8),
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (nameCtrl.text.isEmpty ||
                                  priceCtrl.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Nombre y precio son obligatorios",
                                    ),
                                    backgroundColor: zampaRed,
                                  ),
                                );
                                return;
                              }

                              setModalState(() => _isSaving = true);

                              double finalPrice =
                                  double.tryParse(priceCtrl.text) ?? 0.0;

                              bool success = await ProductService().saveProduct(
                                id: product?.id,
                                name: nameCtrl.text,
                                price: finalPrice,
                                description:
                                    descCtrl.text, // 🔥 Mandamos la descripción
                                categoryId:
                                    selectedCategoryId, // 🔥 Mandamos la categoría
                                imageFile: selectedImage,
                              );

                              setModalState(() => _isSaving = false);

                              if (success) {
                                if (ctx.mounted) Navigator.pop(ctx);
                                context.read<ProductProvider>().fetchProducts();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "¡Producto guardado con éxito!",
                                    ),
                                    backgroundColor: zampaGreen,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Error al guardar en el servidor",
                                    ),
                                    backgroundColor: zampaRed,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: zampaGreen,
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
                              "Guardar Cambios",
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: zampaBlack,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: zampaGreen.withOpacity(0.2),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: const Text(
          "Mi Carta",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductModal(context),
        backgroundColor: zampaBlack,
        icon: const Icon(Icons.add, color: zampaYellow),
        label: const Text(
          "Nuevo Producto",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                bool isAvailable =
                    _availabilityState[product.id] ?? product.isAvailable;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.white : Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: zampaWhite, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Image.network(
                              product.imageUrl ??
                                  'https://ui-avatars.com/api/?name=Zampa',
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                width: 65,
                                height: 65,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.fastfood,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            if (!isAvailable)
                              Container(
                                width: 65,
                                height: 65,
                                color: Colors.white.withOpacity(0.7),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: isAvailable ? zampaBlack : Colors.grey,
                                decoration: isAvailable
                                    ? null
                                    : TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "S/ ${product.price.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: isAvailable ? zampaGreen : Colors.grey,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: zampaYellow.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: zampaYellow,
                            size: 20,
                          ),
                        ),
                        onPressed: () =>
                            _showProductModal(context, product: product),
                      ),
                      Switch(
                        value: isAvailable,
                        activeColor: zampaGreen,
                        activeTrackColor: zampaGreen.withOpacity(0.3),
                        onChanged: (val) async {
                          setState(() => _availabilityState[product.id] = val);
                          bool success = await ProductService()
                              .toggleAvailability(product.id, val);
                          if (!success) {
                            setState(
                              () => _availabilityState[product.id] = !val,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Error de conexión"),
                                backgroundColor: zampaRed,
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
