import 'package:flutter/material.dart';
import 'zampa_data.dart';
import 'product_card.dart';
import 'services/digi_service.dart';
import 'models/digi_model.dart';

class TabMenu extends StatefulWidget {
  const TabMenu({super.key});

  @override
  State<TabMenu> createState() => _TabMenuState();
}

class _TabMenuState extends State<TabMenu> {
  bool isLoading = true;
  List<Product> digiProducts = [];
  
  // Estas serán nuestras nuevas "Categorías" de Digimon
  String selectedLevel = 'Todo';
  final List<String> digiLevels = ['Todo', 'Rookie', 'Champion', 'Ultimate', 'Mega'];

  @override
  void initState() {
    super.initState();
    _loadData(selectedLevel);
  }

  // Función que carga datos según el filtro seleccionado
  Future<void> _loadData(String level) async {
    setState(() => isLoading = true);
    try {
      DigiService service = DigiService();
      List<DigiModel> digimons = await service.getDigimonsByCategory(level);
      
      setState(() {
        digiProducts = digimons.map((digi) {
          return Product(
            name: digi.name,
            price: (digi.id.toDouble() % 50) + 10, // Precio dinámico
            description: "Nivel: $level",
            category: 'Digimon',
            subCategory: level,
            imagePath: digi.image,
          );
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- CABECERA VERDE CON BUSCADOR ---
        Container(
          color: const Color(0xFF81C784),
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar en $selectedLevel...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
        ),

        // --- FILTROS (CHIPS) ---
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Row(
            children: digiLevels.map((level) {
              bool isSelected = selectedLevel == level;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(level),
                  selected: isSelected,
                  selectedColor: const Color(0xFF81C784),
                  onSelected: (val) {
                    setState(() => selectedLevel = level);
                    _loadData(level); // Recarga la API con el nuevo filtro
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // --- LISTADO ---
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.green))
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: digiProducts.length,
                  itemBuilder: (context, index) => ProductCard(product: digiProducts[index]),
                ),
        ),
      ],
    );
  }
}