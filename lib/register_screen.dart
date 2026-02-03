import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Importamos GoRouter
import 'shared_components.dart'; // Usamos tus componentes

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePass = true;
  bool _obscureRepPass = true;

  @override
  Widget build(BuildContext context) {
    return ZampaBackground(
      title: 'Registro',
      showBackArrow: true, // Esto activa la flecha que configuramos en shared_components
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // NOMBRES
          buildLabel('Nombres *'),
          TextField(decoration: zampaInputDecoration()),
          const SizedBox(height: 20),

          // CORREO
          buildLabel('Correo electrónico *'),
          TextField(decoration: zampaInputDecoration()),
          const SizedBox(height: 20),

          // CONTRASEÑA
          buildLabel('Contraseña *'),
          TextField(
            obscureText: _obscurePass,
            decoration: zampaInputDecoration(
              suffixIcon: IconButton(
                icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // REPETIR CONTRASEÑA
          buildLabel('Repita la contraseña *'),
          TextField(
            obscureText: _obscureRepPass,
            decoration: zampaInputDecoration(
              suffixIcon: IconButton(
                icon: Icon(_obscureRepPass ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureRepPass = !_obscureRepPass),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // BOTÓN CREAR CUENTA
          ElevatedButton(
            onPressed: () {
              // Simulación de creación de cuenta
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cuenta creada con éxito. Inicia sesión.'),
                  backgroundColor: Colors.green,
                ),
              );
              
              // Volvemos al Login
              context.go('/'); 
            },
            style: zampaButtonStyle(),
            child: const Text(
              'Crear cuenta', 
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}