import 'package:dio/dio.dart';
import '../models/digi_model.dart';
import '../utils/dio_client.dart';

class DigiService {
  final Dio _dio = DioClient.dio;

  // Modificamos para recibir el nivel (categoría)
  Future<List<DigiModel>> getDigimonsByCategory(String level) async {
    try {
      // Si el nivel es "Todo", traemos la lista general
      String url = (level == 'Todo') ? "/digimon?pageSize=50" : "/digimon?level=$level&pageSize=20";
      
      final response = await _dio.get(url);
      
      if (response.data["content"] == null) return [];
      
      final List listado = response.data["content"];
      return listado.map((e) => DigiModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Error cargando Digimons de tipo $level");
    }
  }
}