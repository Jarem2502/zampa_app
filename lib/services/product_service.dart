import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../utils/dio_client.dart';

class ProductService {
  final Dio _dio = DioClient.dio;

  Future<List<ProductModel>> getProducts() async {
    try {
      // Llamamos a la API real de Zampa
      final response = await _dio.get("/productos");

      if (response.statusCode == 200) {
        final List listado = response.data;
        return listado.map((e) => ProductModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Error en ProductService: $e");
      return [];
    }
  }
}