import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'shared_components.dart';
import 'services/auth_service.dart'; // 🔥 Conexión al backend

// --- PANTALLA 1: INGRESAR CORREO ---
class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleSendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingrese un correo válido')));
      return;
    }

    setState(() => _isLoading = true);
    bool success = await _authService.sendRecoveryCode(email);
    setState(() => _isLoading = false);

    if (success && mounted) {
      context.push(
        '/verificacion',
        extra: email,
      ); // Pasamos el correo a la siguiente pantalla
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo enviar el código. Verifique el correo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZampaBackground(
      title: 'Recuperar cuenta',
      showBackArrow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ingrese su correo electrónico registrado para proceder con la recuperación de su cuenta:',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 30),
          buildLabel('Correo electrónico *'),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: zampaInputDecoration(),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSendCode,
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
                    'Enviar Código',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }
}

// --- PANTALLA 2: CÓDIGO DE VERIFICACIÓN (OTP) ---
class VerificationScreen extends StatefulWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleVerifyCode() async {
    final code = _codeController.text.trim();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese el código de 6 dígitos')),
      );
      return;
    }

    setState(() => _isLoading = true);
    bool success = await _authService.verifyRecoveryCode(widget.email, code);
    setState(() => _isLoading = false);

    if (success && mounted) {
      context.push(
        '/nueva-password',
        extra: {'email': widget.email, 'code': code},
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código incorrecto o expirado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZampaBackground(
      title: 'Verificación',
      showBackArrow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enviamos un código a:\n${widget.email}\n\nIngrese el código de 6 dígitos:',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 30),
          buildLabel('Código de 6 dígitos *'),
          TextField(
            controller: _codeController,
            textAlign: TextAlign.center,
            maxLength: 6,
            style: const TextStyle(
              fontSize: 24,
              letterSpacing: 8,
              fontWeight: FontWeight.bold,
            ),
            keyboardType: TextInputType.number,
            decoration: zampaInputDecoration().copyWith(
              hintText: '000000',
              counterText: '',
              hintStyle: const TextStyle(
                color: Colors.black38,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleVerifyCode,
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
                    'Verificar',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }
}

// --- PANTALLA 3: CREAR NUEVA CONTRASEÑA ---
class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String code;
  const NewPasswordScreen({super.key, required this.email, required this.code});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _pass1Controller = TextEditingController();
  final TextEditingController _pass2Controller = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _isLoading = false;

  void _handleResetPassword() async {
    final pass1 = _pass1Controller.text.trim();
    final pass2 = _pass2Controller.text.trim();

    if (pass1.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
        ),
      );
      return;
    }
    if (pass1 != pass2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => _isLoading = true);
    bool success = await _authService.resetPassword(
      widget.email,
      widget.code,
      pass1,
    );
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Contraseña actualizada con éxito!"),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/'); // Volvemos al Login
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hubo un error al guardar la contraseña.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZampaBackground(
      title: 'Nueva contraseña',
      showBackArrow: false, // Ya no permitimos volver atrás aquí por seguridad
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildLabel('Contraseña nueva *'),
          TextField(
            controller: _pass1Controller,
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
            controller: _pass2Controller,
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
            onPressed: _isLoading ? null : _handleResetPassword,
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
                    'Guardar y Entrar',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }
}
