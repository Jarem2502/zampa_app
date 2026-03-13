import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  bool get isAdmin => _user?.roleId == 1;

  AuthProvider() {
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final token = prefs.getString('auth_token');
    final userName = prefs.getString('user_name') ?? 'Usuario Zampa';
    final userEmail = prefs.getString('user_email') ?? '';
    final userAvatarRaw = prefs.getString('user_avatar');
    final roleId = prefs.getInt('user_role');

    // 🔥 CORRECCIÓN DEL BUG BLANCO: Construimos la URL completa si viene cortada
    String? finalAvatar;
    if (userAvatarRaw != null && userAvatarRaw.isNotEmpty) {
      if (userAvatarRaw.startsWith('http')) {
        finalAvatar = userAvatarRaw;
      } else {
        finalAvatar = 'https://zampa.pro-cafes.com/storage/$userAvatarRaw';
      }
    }

    if (userId != null && token != null) {
      _user = UserModel(
        id: int.tryParse(userId) ?? 0,
        name: userName,
        email: userEmail,
        roleId: roleId,
        token: token,
        avatar: finalAvatar,
      );
    }
    _isLoading = false;
    notifyListeners();
  }

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

  Future<void> _saveUserDetails(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    if (user.roleId != null) {
      await prefs.setInt('user_role', user.roleId!);
    }
    if (user.avatar != null) {
      await prefs.setString('user_avatar', user.avatar!);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> reloadSession() async {
    await _loadUserSession();
  }
}
