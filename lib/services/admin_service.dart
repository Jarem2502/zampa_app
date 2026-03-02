import 'package:dio/dio.dart';
import '../utils/dio_client.dart';

class AdminService {
  final Dio _dio = DioClient.dio;

  // 1. Obtener estadísticas con filtros rápidos (Diario, Semanal, Mensual)
  Future<Map<String, dynamic>> getStats(String filter) async {
    try {
      final response = await _dio.get(
        '/admin/stats',
        queryParameters: {'filter': filter},
      );
      return _mapResponse(response);
    } catch (e) {
      print("Error obteniendo stats (Filtro): $e");
      return {'ventas': 0.0, 'pedidos': 0};
    }
  }

  // 2. Obtener estadísticas por rango de fechas específico (Calendario)
  Future<Map<String, dynamic>> getStatsCustom(String start, String end) async {
    try {
      final response = await _dio.get(
        '/admin/stats',
        queryParameters: {'start_date': start, 'end_date': end},
      );
      return _mapResponse(response);
    } catch (e) {
      print("Error obteniendo stats (Custom): $e");
      return {'ventas': 0.0, 'pedidos': 0};
    }
  }

  // 🔥 Función privada para procesar la respuesta de Laravel sin repetir código
  Map<String, dynamic> _mapResponse(Response response) {
    if (response.statusCode == 200 && response.data != null) {
      return {
        'ventas':
            double.tryParse(response.data['ventas']?.toString() ?? '0') ?? 0.0,
        'pedidos':
            int.tryParse(response.data['pedidos']?.toString() ?? '0') ?? 0,
      };
    }
    return {'ventas': 0.0, 'pedidos': 0};
  }
}
