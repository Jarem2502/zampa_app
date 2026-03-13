import 'dart:convert';
import 'order_detail_model.dart';

class OrderModel {
  final int id;
  final int userId;
  final double total;
  final String status;
  final String paymentMethod;
  final String orderType;
  final String createdAt;
  final int? estimatedTime; // 🔥 NUEVO: Atrapamos los minutos del admin
  final List<OrderDetailModel> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.orderType,
    required this.createdAt,
    this.estimatedTime,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderDetailModel> productList = [];

    if (json['products'] != null) {
      try {
        final List<dynamic> decodedData = json['products'] is String
            ? jsonDecode(json['products'])
            : json['products'];

        productList = decodedData
            .map((item) => OrderDetailModel.fromJson(item))
            .toList();
      } catch (e) {
        print("Error al procesar los productos del pedido #${json['id']}: $e");
      }
    }

    return OrderModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'validating',
      paymentMethod: json['payment_method'] ?? 'Desconocido',
      orderType: json['order_type'] ?? 'Para Llevar',
      createdAt: json['created_at'] ?? '',
      // 🔥 Lee los minutos. Cambia 'estimated_time' si en tu BD se llama diferente (ej: 'tiempo_estimado')
      estimatedTime: json['estimated_time'] != null
          ? int.tryParse(json['estimated_time'].toString())
          : null,
      items: productList,
    );
  }
}
