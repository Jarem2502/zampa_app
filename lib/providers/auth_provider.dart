import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  final AuthService _authService = AuthService();
  bool _isLoading = true; // Para saber si estamos revisando la sesión guardada

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadUserSession();
  }

  // 1. Cargar la sesión apenas se abre la app
  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final token = prefs.getString('auth_token');
    final userName = prefs.getString('user_name') ?? 'Usuario Zampa';
    final userEmail = prefs.getString('user_email') ?? '';

    // Si hay un ID y un Token guardados, reconstruimos el usuario
    if (userId != null && token != null) {
      _user = UserModel(
        id: int.tryParse(userId) ?? 0,
        name: userName,
        email: userEmail,
        token: token,
      );
    }
    _isLoading = false;
    notifyListeners(); // Avisamos a la app que ya terminamos de cargar
  }

  // 2. Iniciar sesión normal
  Future<bool> login(String email, String password) async {
    final loggedUser = await _authService.login(email, password);
    if (loggedUser != null) {
      _user = loggedUser;
      await _saveUserDetails(loggedUser);
      notifyListeners();
      return true;
    }
    return false;
  }

  // 3. Iniciar sesión con Google
  Future<bool> loginWithGoogle() async {
    final loggedUser = await _authService.loginWithGoogle();
    if (loggedUser != null) {
      _user = loggedUser;
      await _saveUserDetails(loggedUser);
      notifyListeners();
      return true;
    }
    return false;
  }

  // 4. Guardar datos extras para cuando se cierre la app
  Future<void> _saveUserDetails(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
  }

  // 5. Cerrar sesión
  Future<void> logout() async {
    await _authService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    _user = null;
    notifyListeners(); // Avisamos a la app para que lo mande al login
  }
}