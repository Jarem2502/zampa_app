import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../utils/dio_client.dart';

class ProductService {
  final Dio _dio = DioClient.dio;

  // Obtenemos los productos reales de tu base de datos
  Future<List<ProductModel>> getProductsByCategory(String categoryName) async {
    try {
      // Llamamos a tu ruta real en Hostinger: https://zampa.pro-cafes.com/api/productos
      final response = await _dio.get("/productos");

      // Laravel devuelve el array directamente, así que lo tomamos de response.data
      final List listado = response.data;

      // Convertimos el JSON de tu SQL a modelos de Flutter
      List<ProductModel> allProducts = listado
          .map((e) => ProductModel.fromJson(e))
          .toList();

      // Filtramos en la app según el Chip que el usuario toque en el menú
      if (categoryName == 'Todo') {
        return allProducts;
      }

      // Si tocó "Hamburguesas", filtramos solo las que tengan esa categoría
      return allProducts
          .where((prod) => prod.categoryName == categoryName)
          .toList();
    } catch (e) {
      print("Error en ProductService: $e");
      throw Exception("Error cargando los productos desde Hostinger");
    }
  }
}
