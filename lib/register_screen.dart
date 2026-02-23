import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'shared_components.dart';
import 'services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();

  bool _obscurePass = true;
  bool _obscureRepPass = true;
  bool _isLoading = false;

  void _handleRegister() async {
    // Evita múltiples clics si ya se está cargando
    if (_isLoading) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final repeatPassword = _repeatPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        repeatPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    if (password != repeatPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Llamada única al backend en Hostinger
      bool success = await _authService.register(name, email, password);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Cuenta creada con éxito. Ya puedes iniciar sesión.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Limpiamos controladores antes de navegar
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _repeatPasswordController.clear();

          context.go('/');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Error al registrar. El correo podría ya estar en uso o hubo un problema de red.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      // Nos aseguramos de liberar el estado de carga pase lo que pase
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZampaBackground(
      title: 'Registro',
      showBackArrow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildLabel('Nombres *'),
          TextField(
            controller: _nameController,
            decoration: zampaInputDecoration(),
          ),
          const SizedBox(height: 20),

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
            obscureText: _obscurePass,
            decoration: zampaInputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePass ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
          ),
          const SizedBox(height: 20),

          buildLabel('Repita la contraseña *'),
          TextField(
            controller: _repeatPasswordController,
            obscureText: _obscureRepPass,
            decoration: zampaInputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRepPass ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscureRepPass = !_obscureRepPass),
              ),
            ),
          ),
          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
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
                    'Crear cuenta',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
