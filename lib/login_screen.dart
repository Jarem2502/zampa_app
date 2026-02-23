import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'shared_components.dart';
import 'services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isObscure = true;
  bool _isLoading = false;

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);
    bool success = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) context.go('/menu');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales incorrectas. Intenta de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- Función para el botón de Google ---
  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    bool success = await _authService.loginWithGoogle();
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) context.go('/menu');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error o cancelación al iniciar con Google.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZampaBackground(
      title: 'Iniciar sesión',
      showBackArrow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildLabel('Correo electrónico *'),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: zampaInputDecoration(),
          ),
          const SizedBox(height: 20),
          buildLabel('Contraseña *'),
          TextField(
            controller: _passwordController,
            obscureText: _isObscure,
            decoration: zampaInputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black54,
                ),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // BOTÓN INICIAR SESIÓN
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: zampaButtonStyle(),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),

          const SizedBox(height: 15),

          // --- BOTÓN DE GOOGLE ---
          // --- BOTÓN DE GOOGLE ---
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleGoogleLogin,
            // CAMBIAMOS EL ICONO AQUÍ 👇
            icon: Image.network(
              'https://w7.pngwing.com/pngs/989/129/png-transparent-google-logo-google-search-meng-meng-company-text-logo.png',
              height: 24,
            ),
            label: const Text(
              'Continuar con Google',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => context.push('/recuperar'),
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            '¿No tienes una cuenta?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => context.push('/registro'),
            style: zampaButtonStyle(),
            child: const Text(
              'Registrate',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => context.push('/admin'),
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
