import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Importante
import 'shared_components.dart';

// --- PANTALLA 1: INGRESAR CORREO ---
class RecoveryScreen extends StatelessWidget { // Le cambié el nombre a RecoveryScreen para coincidir con main.dart
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZampaBackground(
      title: 'Recuperar cuenta',
      showBackArrow: true, // Funciona gracias a shared_components
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ingrese un correo electrónico previamente registrado para proceder con la recuperación de su cuenta:',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 30),
          
          buildLabel('Correo electrónico *'),
          TextField(decoration: zampaInputDecoration()),
          
          const SizedBox(height: 40),
          
          ElevatedButton(
            onPressed: () {
              // IR A VERIFICACIÓN
              context.push('/verificacion'); 
            },
            style: zampaButtonStyle(),
            child: const Text('Continuar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// --- PANTALLA 2: CÓDIGO DE VERIFICACIÓN (OTP) ---
class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZampaBackground(
      title: 'Verificación',
      showBackArrow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Le enviamos un código de verificación a su correo electrónico.\n\nIngrese el código de 6 dígitos en el recuadro de abajo para continuar:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 30),
          
          buildLabel('Código de 6 dígitos *'),
          
          // Input especial para el código
          TextField(
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
            keyboardType: TextInputType.number,
            decoration: zampaInputDecoration().copyWith(
              hintText: '000-000',
              hintStyle: const TextStyle(color: Colors.black38, letterSpacing: 4),
            ),
          ),
          
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Reenviar código', style: TextStyle(color: Colors.red)),
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              // IR A NUEVA CONTRASEÑA
              context.push('/nueva-password');
            },
            style: zampaButtonStyle(),
            child: const Text('Verificar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// --- PANTALLA 3: CREAR NUEVA CONTRASEÑA ---
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  Widget build(BuildContext context) {
    return ZampaBackground(
      title: 'Crear nueva contraseña',
      showBackArrow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildLabel('Contraseña nueva *'),
          TextField(
            obscureText: _obscure1,
            decoration: zampaInputDecoration(
              suffixIcon: IconButton(
                icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure1 = !_obscure1),
              ),
            ),
          ),
          const SizedBox(height: 20),

          buildLabel('Repita la contraseña *'),
          TextField(
            obscureText: _obscure2,
            decoration: zampaInputDecoration(
              suffixIcon: IconButton(
                icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure2 = !_obscure2),
              ),
            ),
          ),
          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: () {
              // AL TERMINAR, DEVOLVEMOS AL LOGIN (Borramos historial)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Contraseña actualizada")),
              );
              context.go('/'); 
            },
            style: zampaButtonStyle(),
            child: const Text('Continuar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}