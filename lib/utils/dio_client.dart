import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static const String domain = 'https://zampa.pro-cafes.com';

  static final Dio dio = _createDio();

  static Dio _createDio() {
    var dio = Dio(
      BaseOptions(
        baseUrl: '$domain/api',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // EL VIGILANTE DE SEGURIDAD
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();

          // 🔥 Buscamos exactamente el 'auth_token' que guardaste en el login
          final token = prefs.getString('auth_token');

          // Si existe, lo adjuntamos como pase VIP
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          print(
            "Error de Dio: ${e.response?.statusCode} - ${e.response?.data}",
          );
          return handler.next(e);
        },
      ),
    );

    return dio;
  }

  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$domain/storage/$path';
  }
}
