import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http_parser/http_parser.dart';
import '../utils/dio_client.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = DioClient.dio;

  // Si usas google-services.json correctamente, normalmente puedes dejarlo null.
  // Si luego ves que no levanta en Android, coloca aquí tu WEB CLIENT ID.
  static const String? _serverClientId = null;

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

  Future<UserModel?> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: _serverClientId,
      );

      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print("Login con Google cancelado.");
        return null;
      }

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

      print("Respuesta inesperada Google Login: ${response.statusCode}");
      return null;
    } catch (e) {
      print("Error Google Login: $e");
      return null;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {'username': name, 'email': email, 'password': password},
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

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
        data: {'email': email, 'password': newPassword},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProfile(
    String newName,
    String newPassword, {
    List<int>? imageBytes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      FormData formData = FormData.fromMap({'username': newName});

      if (newPassword.isNotEmpty) {
        formData.fields.add(MapEntry('password', newPassword));
      }

      if (imageBytes != null) {
        formData.files.add(
          MapEntry(
            'avatar',
            MultipartFile.fromBytes(
              imageBytes,
              filename: 'perfil.jpg',
              contentType: MediaType('image', 'jpeg'),
            ),
          ),
        );
      }

      final response = await _dio.post('/users/$userId', data: formData);

      if (response.statusCode == 200) {
        await prefs.setString('user_name', newName);

        if (response.data['user'] != null &&
            response.data['user']['avatar'] != null) {
          String rawAvatar = response.data['user']['avatar'];
          String fullAvatar = rawAvatar.startsWith('http')
              ? rawAvatar
              : 'https://zampa.pro-cafes.com/storage/$rawAvatar';
          await prefs.setString('user_avatar', fullAvatar);
        }
        return true;
      }

      return false;
    } catch (e) {
      print("Error actualizando perfil: $e");
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: _serverClientId,
      );
      await googleSignIn.signOut();

      await _dio.post('/logout');
      await prefs.clear();
      return true;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return true;
    }
  }
}
