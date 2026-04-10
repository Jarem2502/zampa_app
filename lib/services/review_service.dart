import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review_model.dart';
import '../utils/dio_client.dart';

class ReviewService {
  final Dio _dio = DioClient.dio;

  Future<List<ReviewModel>> getReviews() async {
    try {
      final response = await _dio.get('/reviews');
      if (response.statusCode == 200) {
        final List listado = response.data;
        return listado.map((e) => ReviewModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Error obteniendo reseñas: $e");
      return [];
    }
  }

  // 🔥 Ya no pide el productId
  Future<bool> sendReview({
    required int rating,
    required String comment,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) return false;

      final response = await _dio.post(
        '/reviews',
        data: {'user_id': userId, 'rating': rating, 'comment': comment},
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error enviando reseña: $e");
      return false;
    }
  }
}
