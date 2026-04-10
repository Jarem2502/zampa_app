import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Importamos para poder usar context.pop()

// 1. EL FONDO BASE (El wrapper que lleva la marca de agua)
class ZampaBackground extends StatelessWidget {
  final Widget child;
  final String title;
  final bool showBackArrow;

  const ZampaBackground({
    super.key,
    required this.child,
    this.title = '',
    this.showBackArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Configuración de la flecha atrás
        leading: showBackArrow
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  // --- CAMBIO GO_ROUTER ---
                  // Si hay historial, volvemos atrás.
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    // Si por alguna razón no se puede volver, vamos al inicio
                    context.go('/');
                  }
                },
              )
            : null,
      ),
      body: Stack(
        children: [
          // MARCA DE AGUA (Logo)
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Image.asset(
                  'assets/zampalogo.png', // Asegúrate de que esta imagen exista
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // CONTENIDO DE LA PANTALLA
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    if (title.isNotEmpty) ...[
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                    child, // El formulario específico
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 2. ESTILO DE LOS INPUTS (Cajas Grises)
InputDecoration zampaInputDecoration({String? label, Widget? suffixIcon}) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.grey[300],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    suffixIcon: suffixIcon,
  );
}

// 3. ETIQUETA NEGRITA ENCIMA DEL INPUT
Widget buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ),
  );
}

// 4. BOTÓN ESTILO OSCURO
ButtonStyle zampaButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF333333),
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}