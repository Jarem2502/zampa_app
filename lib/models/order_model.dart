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
  final List<OrderDetailModel> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.orderType,
    required this.createdAt,
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
      paymentMethod: json['payment_method'] ?? '',
      orderType: json['order_type'] ?? 'Delivery',
      createdAt: json['created_at'] ?? '',
      items: productList,
    );
  }
}
