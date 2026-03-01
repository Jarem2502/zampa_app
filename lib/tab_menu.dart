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

  // Mapeo exacto de las categorías de tu SQL a la app
  final Map<String, int> subCategoryIds = {
    'Hamburguesas': 1,
    'Salchipapas': 2,
    'Sándwiches': 3,
    'Enchiladas': 4,
    'Especiales': 5,
    'Bebidas Frías': 6,
    'Cafés': 7,
    'Jugos': 8,
    'Bebidas Calientes': 11,
  };

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final fetched = await ProductService().getProducts();
      if (mounted) {
        setState(() {
          // Filtramos solo los que están disponibles
          allProducts = fetched;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentSubCategories = (mainCategory == 'Bebidas')
        ? ['Todo', 'Bebidas Frías', 'Cafés', 'Jugos', 'Bebidas Calientes']
        : [
            'Todo',
            'Hamburguesas',
            'Salchipapas',
            'Sándwiches',
            'Enchiladas',
            'Especiales',
          ];

    List<ProductModel> filteredProducts = allProducts.where((p) {
      bool isBebida = [6, 7, 8, 11].contains(p.categoryId);
      if (mainCategory == 'Alimentos' && isBebida) return false;
      if (mainCategory == 'Bebidas' && !isBebida) return false;

      if (selectedSubCategory != 'Todo') {
        int? targetId = subCategoryIds[selectedSubCategory];
        return p.categoryId == targetId;
      }
      return true;
    }).toList();

    return Column(
      children: [
        Container(
          color: const Color(0xFF81C784),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: '¿Qué se te antoja en Zampa?',
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
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : Column(
                  children: [
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
                              onSelected: (val) =>
                                  setState(() => selectedSubCategory = subCat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(
                      child: filteredProducts.isEmpty
                          ? const Center(
                              child: Text("No hay productos disponibles"),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.75,
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 15,
                                  ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) =>
                                  ProductCard(product: filteredProducts[index]),
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
        onTap: () => setState(() {
          mainCategory = title;
          selectedSubCategory = 'Todo';
        }),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
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
