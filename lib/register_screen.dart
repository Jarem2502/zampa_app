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

    // 1. Validar campos vacíos
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        repeatPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    // 2. Validar formato de correo básico
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un correo electrónico válido')),
      );
      return;
    }

    // 3. Validar longitud de contraseña
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
        ),
      );
      return;
    }

    // 4. Validar que contraseñas coincidan
    if (password != repeatPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Llamada al servicio
    bool success = await _authService.register(name, email, password);

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Cuando configuremos Laravel, aquí redirigiremos a la pantalla de Verificación OTP
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '¡Cuenta creada! Próximamente te pediremos validar tu correo.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/'); // Volvemos al login por ahora
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error al crear cuenta. El correo podría ya estar registrado.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          buildLabel('Nombre completo *'),
          TextField(
            controller: _nameController,
            decoration: zampaInputDecoration(),
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 20),

          buildLabel('Correo electrónico *'),
          TextField(
            controller: _emailController,
            decoration: zampaInputDecoration(),
            keyboardType: TextInputType.emailAddress,
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
