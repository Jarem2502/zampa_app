import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/dio_client.dart';

class AuthService {
  final Dio _dio = DioClient.dio;

  // --- INICIAR SESIÓN TRADICIONAL ---
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        return true;
      }
      return false;
    } catch (e) {
      print("Error en login: $e");
      return false;
    }
  }

  // --- LOGIN CON GOOGLE ---
  Future<bool> loginWithGoogle() async {
    try {
      // Configuramos el cliente con tu ID obtenido de Google Cloud
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '834264942658-fai8mqcfefifegt30bg7kh4fm2lvm95e.apps.googleusercontent.com',
      );

      // Limpiamos cualquier sesión previa para que siempre pida elegir cuenta
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return false; // El usuario canceló

      // Enviamos el correo y nombre a tu Laravel en Hostinger
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
        return true;
      }
      return false;
    } catch (e) {
      print("Error detallado en Google Login: $e");
      return false;
    }
  }

  // --- REGISTRO ---
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
        print(
          "Error del servidor (${e.response?.statusCode}): ${e.response?.data}",
        );
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
  }
}
