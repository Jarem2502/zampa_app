import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para Clipboard
import 'package:go_router/go_router.dart'; // Navegación

class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String appLink = "https://zampa.pe/descargar";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(), // CAMBIO: GoRouter
        ),
        title: const Text(
          "Invitar Amigos", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.share_location_outlined, size: 80, color: Colors.blue[400]),
            ),
            const SizedBox(height: 30),
            const Text(
              "¡Comparte Zampa!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "Si te gusta nuestra comida, compártela con tus amigos para que ellos también disfruten.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Enlace de la App", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(height: 10),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      appLink,
                      style: TextStyle(fontSize: 16, color: Colors.grey[800], overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: appLink));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Enlace copiado"),
                          backgroundColor: Colors.black,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text("Copiar", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}