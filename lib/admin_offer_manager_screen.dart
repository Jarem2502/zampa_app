import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Importante para volver atrás

class AdminOfferManagerScreen extends StatefulWidget {
  const AdminOfferManagerScreen({super.key});

  @override
  State<AdminOfferManagerScreen> createState() => _AdminOfferManagerScreenState();
}

class _AdminOfferManagerScreenState extends State<AdminOfferManagerScreen> {
  // Lista simulada de productos (En el futuro vendrá de tu base de datos)
  List<Map<String, dynamic>> products = [
    {
      'name': 'Hamburguesa Royal',
      'price': 22.00,
      'isPromo': false,
      'promoPrice': 0.0,
    },
    {
      'name': 'Club Sándwich',
      'price': 18.00,
      'isPromo': true,
      'promoPrice': 14.50,
    },
    {
      'name': 'Frappé Oreo',
      'price': 12.00,
      'isPromo': false,
      'promoPrice': 0.0,
    },
    {
      'name': 'Salchipapa Zampa',
      'price': 25.00,
      'isPromo': false,
      'promoPrice': 0.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.black,
        // Usamos context.pop() para regresar al Dashboard de Admin
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(), 
        ),
        title: const Text(
          "Gestor de Ofertas",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final prod = products[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: prod['isPromo'] ? Colors.red[50] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lunch_dining,
                  color: prod['isPromo'] ? Colors.red : Colors.grey,
                ),
              ),
              title: Text(
                prod['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: prod['isPromo']
                  ? Text(
                      "Oferta activa: S/ ${prod['promoPrice']}",
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    )
                  : Text("Precio regular: S/ ${prod['price']}"),
              trailing: const Icon(Icons.edit, size: 20),
              onTap: () => _showEditOfferDialog(index),
            ),
          );
        },
      ),
    );
  }

  // --- FORMULARIO FLOTANTE (BOTTOM SHEET) ---
  void _showEditOfferDialog(int index) {
    final prod = products[index];
    final TextEditingController priceController = TextEditingController(
      text: prod['isPromo'] ? prod['promoPrice'].toString() : prod['price'].toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Editar Oferta: ${prod['name']}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text("Precio Original: S/ ${prod['price']}", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              const Text("Precio de Oferta (S/)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 30),

              // BOTÓN GUARDAR
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      products[index]['isPromo'] = true;
                      products[index]['promoPrice'] = double.tryParse(priceController.text) ?? 0.0;
                    });
                    context.pop(); // Cerramos el bottom sheet
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("¡Oferta aplicada a ${prod['name']}!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Aplicar Descuento", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              if (prod['isPromo'])
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() => products[index]['isPromo'] = false);
                      context.pop();
                    },
                    child: const Text("Eliminar Oferta", style: TextStyle(color: Colors.red)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}