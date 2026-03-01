import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../utils/dio_client.dart';

class ProductService {
  final Dio _dio = DioClient.dio;

  // Trae todos los productos y los convierte en tu modelo limpio
  Future<List<ProductModel>> getProducts() async {
    try {
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

  // 🔥 NUEVO: Función exclusiva para el Administrador
  Future<bool> updateProductPromo(
    int productId,
    bool isPromo,
    double promoPrice,
  ) async {
    try {
      final response = await _dio.put(
        "/productos/$productId/promo",
        data: {'is_promo': isPromo ? 1 : 0, 'promo_price': promoPrice},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error actualizando oferta: $e");
      return false;
    }
  }
}
