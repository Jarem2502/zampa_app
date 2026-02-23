import 'package:dio/dio.dart';

class DioClient {
  static const String domain = 'https://zampa.pro-cafes.com';

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: '$domain/api',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json', // Importante para Laravel
      },
    ),
  );

  // Helper para armar la URL completa de las fotos
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$domain/storage/$path';
  }
}
