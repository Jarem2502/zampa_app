import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importa tus archivos reales si ya los tienes, si no, usa los de abajo.
import 'zampa_data.dart';
// import 'product_card.dart';

class TabMenu extends StatefulWidget {
  const TabMenu({super.key});

  @override
  State<TabMenu> createState() => _TabMenuState();
}

class _TabMenuState extends State<TabMenu> {
  // --- ESTADO ---
  String mainCategory = 'Bebidas';
  String selectedSubCategory = 'Todo';

  final List<String> bebidasSubs = ['Todo', 'Cafés', 'Bebidas Frías', 'Jugos'];
  final List<String> alimentosSubs = ['Todo', 'Sándwich', 'Hamburguesas', 'Salchipapas', 'Especiales'];

  @override
  Widget build(BuildContext context) {
    // 1. Definir qué subcategorías mostrar
    List<String> currentSubCategories = (mainCategory == 'Bebidas') ? bebidasSubs : alimentosSubs;

    // 2. Filtrar la lista de productos (Usando la data simulada de abajo)
    List<Product> filteredProducts = allProducts.where((p) {
      if (p.category != mainCategory) return false;
      if (selectedSubCategory != 'Todo' && p.subCategory != selectedSubCategory) return false;
      return true;
    }).toList();

    return Column(
      children: [
        // --- CABECERA VERDE (Buscador y Pestañas) ---
        Container(
          color: const Color(0xFF81C784), // Verde suave
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              // Buscador
              TextField(
                decoration: InputDecoration(
                  hintText: '¿Qué se te antoja?',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
              const SizedBox(height: 10),
              // Pestañas Principales (Bebidas vs Alimentos)
              Row(
                children: [
                  _buildMainTab('Bebidas'),
                  _buildMainTab('Alimentos'),
                ],
              ),
            ],
          ),
        ),

        // --- CUERPO PRINCIPAL ---
        Expanded(
          child: Stack(
            children: [
              // Fondo con marca de agua (Opcional, si tienes la imagen)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: Center(
                    child: Icon(Icons.fastfood, size: 200, color: Colors.grey),
                    // Image.asset('assets/zampalogo.png'),
                  ),
                ),
              ),

              // Contenido Real
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Lista horizontal de filtros (Chips)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    child: Row(
                      children: currentSubCategories.map((subCat) {
                        bool isSelected = selectedSubCategory == subCat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(subCat),
                            selected: isSelected,
                            backgroundColor: Colors.grey[100],
                            selectedColor: const Color(0xFF81C784),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: const StadiumBorder(),
                            side: BorderSide.none,
                            onSelected: (bool selected) {
                              setState(() {
                                selectedSubCategory = subCat;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Título de sección
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "$mainCategory - $selectedSubCategory",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  const SizedBox(height: 10),

                  // Grid de Productos
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? const Center(child: Text("No hay productos aquí :("))
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 columnas
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio: 0.75, // Proporción tarjeta (alto/ancho)
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              
                              return GestureDetector(
                                onTap: () {
                                  // --- AQUÍ USAMOS GO_ROUTER ---
                                  // Enviamos el objeto 'product' completo a la siguiente pantalla
                                  context.push('/detalle', extra: product);
                                },
                                child: ProductCard(
                                  title: product.name,
                                  price: product.price.toStringAsFixed(2),
                                  // imageUrl: product.image, // Si tuvieras imagen
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget para las pestañas de arriba (Bebidas / Alimentos)
  Widget _buildMainTab(String title) {
    bool isActive = mainCategory == title;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            mainCategory = title;
            selectedSubCategory = 'Todo'; // Resetear subfiltro
          });
        },
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isActive ? Colors.black : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              color: isActive ? Colors.black : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

// Tarjeta de Producto (Diseño Visual)
class ProductCard extends StatelessWidget {
  final String title;
  final String price;

  const ProductCard({super.key, required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen gris (simulada)
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: const Icon(Icons.fastfood, size: 40, color: Colors.white),
            ),
          ),
          // Textos
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('S/ $price', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}