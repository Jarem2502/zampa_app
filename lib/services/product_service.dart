import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../utils/dio_client.dart';

class ProductService {
  final Dio _dio = DioClient.dio;

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

  Future<bool> updateProductPromo(
    int productId,
    bool isPromo,
    double promoPrice, {
    String? name,
    String? start,
    String? end,
  }) async {
    try {
      final response = await _dio.put(
        "/productos/$productId/promo",
        data: {
          'is_promo': isPromo ? 1 : 0,
          'promo_price': promoPrice,
          'promo_name': name,
          'promo_start': start,
          'promo_end': end,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 🔥 CREAR O ACTUALIZAR CON FOTO, DESCRIPCIÓN Y CATEGORÍA
  Future<bool> saveProduct({
    int? id,
    required String name,
    required double price,
    required String description, // <-- Nuevo
    required int categoryId, // <-- Nuevo
    XFile? imageFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'price': price,
        'description': description,
        'category_id': categoryId,
      });

      if (id != null) {
        formData.fields.add(const MapEntry('_method', 'PUT'));
      }

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        formData.files.add(
          MapEntry(
            'image',
            MultipartFile.fromBytes(bytes, filename: imageFile.name),
          ),
        );
      }

      final response = await _dio.post(
        id == null ? '/admin/productos' : '/admin/productos/$id',
        data: formData,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error guardando producto: $e");
      return false;
    }
  }

  // 🔥 SWITCH DE DISPONIBILIDAD
  Future<bool> toggleAvailability(int productId, bool isAvailable) async {
    try {
      final response = await _dio.put(
        "/admin/productos/$productId/disponibilidad",
        data: {'is_available': isAvailable ? 1 : 0},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
