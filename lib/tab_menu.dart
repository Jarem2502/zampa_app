import 'package:flutter/material.dart';
import 'product_card.dart';
import 'services/product_service.dart';
import 'models/product_model.dart';

class TabMenu extends StatefulWidget {
  const TabMenu({super.key});

  @override
  State<TabMenu> createState() => _TabMenuState();
}

class _TabMenuState extends State<TabMenu> {
  bool isLoading = true;
  List<ProductModel> allProducts = [];

  String mainCategory = 'Alimentos';
  String selectedSubCategory = 'Todo';

  // Categorías basadas en tu base de datos SQL
  final List<String> bebidasSubs = [
    'Todo',
    'Bebidas Frías',
    'Cafés',
    'Jugos',
    'Bebidas Calientes',
    'Tés Frutados',
  ];
  final List<String> alimentosSubs = [
    'Todo',
    'Hamburguesas',
    'Salchipapas',
    'Sándwiches',
    'Enchiladas',
    'Especiales',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      ProductService service = ProductService();
      // Traemos todo el catálogo de tu Laravel
      List<ProductModel> fetched = await service.getProductsByCategory('Todo');
      setState(() {
        allProducts = fetched;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error cargando menú: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentSubCategories = (mainCategory == 'Bebidas')
        ? bebidasSubs
        : alimentosSubs;

    // Filtramos los productos de la BD para mostrarlos en la pestaña correcta
    List<ProductModel> filteredProducts = allProducts.where((p) {
      bool isBebida = bebidasSubs.contains(p.categoryName);
      bool isAlimento = alimentosSubs.contains(p.categoryName);

      if (mainCategory == 'Bebidas' && !isBebida) return false;
      if (mainCategory == 'Alimentos' && !isAlimento) return false;

      if (selectedSubCategory != 'Todo' &&
          p.categoryName != selectedSubCategory)
        return false;
      return true;
    }).toList();

    return Column(
      children: [
        // CABECERA VERDE
        Container(
          color: const Color(0xFF81C784),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: '¿Qué se te antoja hoy?',
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
              Row(
                children: [
                  _buildMainTab('Alimentos'),
                  _buildMainTab('Bebidas'),
                ],
              ),
            ],
          ),
        ),

        // LISTADO DE PRODUCTOS
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FILTROS HORIZONTALES (CHIPS)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      child: Row(
                        children: currentSubCategories.map((subCat) {
                          bool isSelected = selectedSubCategory == subCat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(subCat),
                              selected: isSelected,
                              selectedColor: const Color(0xFF81C784),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              onSelected: (selected) {
                                setState(() => selectedSubCategory = subCat);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // GRILLA DE PRODUCTOS
                    Expanded(
                      child: filteredProducts.isEmpty
                          ? const Center(
                              child: Text("No hay productos en esta categoría"),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 15,
                                    childAspectRatio: 0.8,
                                  ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                return ProductCard(
                                  product: filteredProducts[index],
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMainTab(String title) {
    bool isActive = mainCategory == title;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            mainCategory = title;
            selectedSubCategory = 'Todo';
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
