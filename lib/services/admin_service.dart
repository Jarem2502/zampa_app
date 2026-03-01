import 'package:dio/dio.dart';
import '../utils/dio_client.dart';

class AdminService {
  final Dio _dio = DioClient.dio;

  // Pide a Laravel las estadísticas resumidas
  Future<Map<String, dynamic>> getStats(String filter) async {
    try {
      // El filtro enviará 'Diario', 'Semanal' o 'Mensual'
      final response = await _dio.get(
        '/admin/stats',
        queryParameters: {'filter': filter},
      );

      if (response.statusCode == 200) {
        return {
          'ventas':
              double.tryParse(response.data['ventas']?.toString() ?? '0') ??
              0.0,
          'pedidos':
              int.tryParse(response.data['pedidos']?.toString() ?? '0') ?? 0,
        };
      }
      return {'ventas': 0.0, 'pedidos': 0};
    } catch (e) {
      print("Error obteniendo stats de admin: $e");
      return {'ventas': 0.0, 'pedidos': 0};
    }
  }
}
