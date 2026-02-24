class OrderItemModel {
  final int productId;
  final String name;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? 'Producto',
      quantity: json['quantity'] ?? 1,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}