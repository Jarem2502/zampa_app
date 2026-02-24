import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/dio_client.dart';
import '../models/user_model.dart'; // 🔥 Importamos tu nuevo modelo

class AuthService {
  final Dio _dio = DioClient.dio;

  // --- INICIAR SESIÓN TRADICIONAL ---
  // Ahora devuelve un UserModel? en lugar de bool
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        final userData = response.data['user'] ?? response.data;
        
        if (userData != null && userData['id'] != null) {
          await prefs.setString('user_id', userData['id'].toString());
        }

        // 🔥 Convertimos el JSON crudo en un objeto Dart elegante
        return UserModel.fromJson(userData, authToken: token);
      }
      return null;
    } catch (e) {
      print("Error en login: $e");
      return null;
    }
  }

  // --- LOGIN CON GOOGLE ---
  // También devuelve UserModel?
  Future<UserModel?> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '834264942658-fai8mqcfefifegt30bg7kh4fm2lvm95e.apps.googleusercontent.com',
      );

      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // El usuario canceló

      final response = await _dio.post(
        '/auth/google',
        data: {
          'email': googleUser.email,
          'username': googleUser.displayName ?? 'Usuario Google',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        final userData = response.data['user'] ?? response.data;
        if (userData != null && userData['id'] != null) {
          await prefs.setString('user_id', userData['id'].toString());
        }

        // 🔥 Retornamos el modelo listo para usar
        return UserModel.fromJson(userData, authToken: token);
      }
      return null;
    } catch (e) {
      print("Error detallado en Google Login: $e");
      return null;
    }
  }

  // --- REGISTRO ---
  // Este se puede quedar como bool porque generalmente después de registrar
  // mandas al usuario a la pantalla de login.
  Future<bool> register(String username, String email, String password) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {'username': username, 'email': email, 'password': password},
      );
      print("Registro exitoso en servidor: ${response.data}");
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        print("Error del servidor (${e.response?.statusCode}): ${e.response?.data}");
      } else {
        print("Error de conexión: ${e.message}");
      }
      return false;
    } catch (e) {
      print("Error inesperado: $e");
      return false;
    }
  }

  // --- CERRAR SESIÓN ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
  }
}