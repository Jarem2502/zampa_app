import 'package:dio/dio.dart';
import '../utils/dio_client.dart';
import 'package:http_parser/http_parser.dart';

class OrderService {
  final Dio _dio = DioClient.dio;

  Future<bool> sendOrder({
    required Map<String, dynamic> orderData,
    required String imagePath,
    required List<int> imageBytes,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': orderData['user_id'].toString(),
        'total': orderData['total'].toString(),
        'payment_method': orderData['payment_method'],
        'order_type': orderData['order_type'],
        'client_name': orderData['client_name'],
        'dni': orderData['dni'] ?? '',
        'products': orderData['products'].toString(),
        'receipt': MultipartFile.fromBytes(
          imageBytes,
          filename: 'voucher.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await _dio.post('/orders', data: formData);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error Laravel enviando pedido: $e");
      return false;
    }
  }

  Future<List<dynamic>> getMyOrders() async {
    try {
      final response = await _dio.get('/orders');
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      print("Error obteniendo pedidos: $e");
      return [];
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    try {
      final response = await _dio.patch('/orders/$orderId/cancel');
      return response.statusCode == 200;
    } catch (e) {
      print("Error cancelando pedido: $e");
      return false;
    }
  }
}
