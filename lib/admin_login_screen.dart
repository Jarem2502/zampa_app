import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

const Color zampaGreen = Color(0xFF1A9956);
const Color zampaRed = Color(0xFFE53935);

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  
  bool _isLoading = false;
  bool _isObscure = true; // 🔥 Nuevo estado para controlar el "ojito"

  void _handleAdminLogin() async {
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor ingrese correo y contraseña"), 
          backgroundColor: zampaRed
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();

    // Intentamos loguear con el backend real
    bool success = await authProvider.login(
      _emailController.text.trim(),
      _passController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Verificamos si el usuario de la BD tiene el rol 1 (Administrador)
      if (authProvider.user?.roleId == 1) {
        context.go('/admin-dashboard');
      } else {
        authProvider.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Acceso denegado: No tienes permisos de Administrador"), 
            backgroundColor: zampaRed
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Credenciales incorrectas"), 
          backgroundColor: zampaRed
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Fondo gris claro elegante
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- CABECERA (Escudo de Seguridad Admin) ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: zampaGreen.withOpacity(0.3), 
                      blurRadius: 20, 
                      spreadRadius: 5
                    ), // Glow verde Zampa
                  ],
                ),
                child: const Icon(Icons.admin_panel_settings, size: 60, color: zampaGreen),
              ),
              const SizedBox(height: 24),
              const Text(
                "Portal Administrativo",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Acceso seguro exclusivo para personal Zampa",
                style: TextStyle(color: Colors.black54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- FORMULARIO TIPO TARJETA FLOTANTE ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Correo Electrónico", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Correo Eslectronico",
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.black54),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: zampaGreen, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text("Contraseña", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passController,
                      obscureText: _isObscure, // 🔥 APLICAMOS EL ESTADO
                      decoration: InputDecoration(
                        hintText: "••••••••",
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54),
                        // 🔥 BOTÓN DEL OJITO AGREGADO AQUÍ
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility_off : Icons.visibility, 
                            color: Colors.grey[600]
                          ),
                          onPressed: () => setState(() => _isObscure = !_isObscure),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: zampaGreen, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- BOTÓN DE LOGIN ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleAdminLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24, width: 24, 
                                child: CircularProgressIndicator(color: zampaGreen, strokeWidth: 3)
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Ingresar al Sistema", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}