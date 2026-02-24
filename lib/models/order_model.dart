import 'dart:convert';
import 'order_detail_model.dart'; // 🔥 Importamos el nuevo modelo de detalle

class OrderModel {
  final int id;
  final int userId;
  final double total;
  final String status;
  final String paymentMethod;
  final String orderType;
  final String createdAt;
  final List<OrderDetailModel> items; // 🔥 CAMBIO: Ya no es String, ahora es Lista

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
    // 🔥 Lógica para convertir el JSON de la base de datos en objetos Dart
    List<OrderDetailModel> productList = [];
    
    if (json['products'] != null) {
      try {
        // En tu SQL, el campo 'products' se guarda como un JSON string
        final List<dynamic> decodedData = json['products'] is String 
            ? jsonDecode(json['products']) 
            : json['products'];
            
        productList = decodedData.map((item) => OrderDetailModel.fromJson(item)).toList();
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
      items: productList, // 🔥 Lista de objetos lista para usar en la UI
    );
  }
}