import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/dio_client.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = DioClient.dio;

  // --- 1. LOGIN TRADICIONAL ---
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
        return UserModel.fromJson(userData, authToken: token);
      }
      return null;
    } catch (e) {
      print("Error en login: $e");
      return null;
    }
  }

  // --- 2. LOGIN CON GOOGLE ---
  Future<UserModel?> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

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
        return UserModel.fromJson(userData, authToken: token);
      }
      return null;
    } catch (e) {
      print("Error en Google Login: $e");
      return null;
    }
  }

  // --- 3. REGISTRO ---
  Future<bool> register(String username, String email, String password) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {'username': username, 'email': email, 'password': password},
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- 4. RECUPERACIÓN DE CONTRASEÑA (CÓDIGO DE 6 DÍGITOS) ---
  Future<bool> sendRecoveryCode(String email) async {
    try {
      final response = await _dio.post(
        '/password/email',
        data: {'email': email},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyRecoveryCode(String email, String code) async {
    try {
      final response = await _dio.post(
        '/password/verify-code',
        data: {'email': email, 'code': code},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final response = await _dio.post(
        '/password/reset',
        data: {
          'email': email,
          'code': code,
          'password': newPassword,
          'password_confirmation': newPassword,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- ACTUALIZAR PERFIL (CON FOTO OPCIONAL) ---
  Future<bool> updateProfile(
    String newName,
    String newPassword, {
    String? imagePath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      // Usamos FormData para poder mandar archivos pesados como fotos
      FormData formData = FormData.fromMap({
        '_method':
            'PUT', // Laravel necesita esto cuando enviamos archivos con método POST
        'username': newName,
      });

      if (newPassword.isNotEmpty) {
        formData.fields.add(MapEntry('password', newPassword));
      }

      // Si el usuario seleccionó una imagen, la adjuntamos
      if (imagePath != null) {
        formData.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(imagePath, filename: 'perfil.jpg'),
          ),
        );
      }

      // Usamos post porque enviar archivos con put en FormData suele dar problemas en algunos servidores
      final response = await _dio.post('/users/$userId', data: formData);

      if (response.statusCode == 200) {
        await prefs.setString('user_name', newName);
        return true;
      }
      return false;
    } catch (e) {
      print("Error actualizando perfil: $e");
      return false;
    }
  }

  // --- 5. LOGOUT ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
  }
}
