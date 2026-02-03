import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'shared_components.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    // Usamos tu plantilla de fondo existente
    return ZampaBackground(
      title: 'Iniciar sesión',
      showBackArrow: false, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          // --- CAMPO CORREO ---
          buildLabel('Correo electrónico *'),
          TextField(decoration: zampaInputDecoration()),
          const SizedBox(height: 20),

          // --- CAMPO CONTRASEÑA ---
          buildLabel('Contraseña *'),
          TextField(
            obscureText: _isObscure,
            decoration: zampaInputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- BOTÓN INICIAR SESIÓN ---
          ElevatedButton(
            onPressed: () {
              // USAMOS GO_ROUTER:
              // context.go reemplaza la pantalla actual (no puedes volver atrás al login)
              context.go('/menu'); 
            },
            style: zampaButtonStyle(),
            child: const Text(
              'Iniciar sesión',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),

          // --- LINK OLVIDASTE CONTRASEÑA ---
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                // context.push apila la pantalla (puedes volver con la flecha)
                context.push('/recuperar');
              },
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // --- TEXTO ¿NO TIENES CUENTA? ---
          const Text(
            '¿No tienes una cuenta?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // --- BOTÓN REGISTRATE ---
          ElevatedButton(
            onPressed: () {
              context.push('/registro');
            },
            style: zampaButtonStyle(),
            child: const Text(
              'Registrate',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 40),

          // --- LINK ADMINISTRADOR ---
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                context.push('/admin');
              },
              child: const Text(
                "¿Eres administrador?",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}