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
  final int? estimatedTime;
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

  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isActive => !isDelivered && !isCancelled;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderDetailModel> productList = [];

    if (json['products'] != null) {
      try {
        final dynamic rawProducts = json['products'];

        final List<dynamic> decodedData = rawProducts is String
            ? jsonDecode(rawProducts)
            : (rawProducts as List<dynamic>);

        productList = decodedData
            .map(
              (item) =>
                  OrderDetailModel.fromJson(Map<String, dynamic>.from(item)),
            )
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
      estimatedTime: json['estimated_time'] != null
          ? int.tryParse(json['estimated_time'].toString())
          : null,
      items: productList,
    );
  }
}
