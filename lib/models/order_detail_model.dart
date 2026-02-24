class OrderDetailModel {
  final String name;
  final int quantity;
  final double price;
  final String? image;

  OrderDetailModel({
    required this.name,
    required this.quantity,
    required this.price,
    this.image,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      name: json['name'] ?? 'Producto',
      quantity: json['quantity'] ?? 1,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      image: json['image'],
    );
  }
}