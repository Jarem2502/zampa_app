import 'package:dio/dio.dart';
import '../models/table_model.dart';
import '../utils/dio_client.dart';

class TableService {
  final Dio _dio = DioClient.dio;

  Future<List<TableModel>> getTables() async {
    try {
      final response = await _dio.get('/tables');

      if (response.statusCode == 200) {
        final List listado = response.data;
        return listado.map((e) => TableModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Error obteniendo mesas: $e");
      return [];
    }
  }
}
