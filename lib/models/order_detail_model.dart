class OrderDetailModel {
  final String name;
  final int quantity;

  // Precio original
  final double price;

  // Precio final con descuento
  final double finalPrice;

  // Precio listo para mostrar
  final double displayPrice;

  final double discountPercentage;
  final double discountAmount;
  final bool hasDiscount;

  final String? image;

  OrderDetailModel({
    required this.name,
    required this.quantity,
    required this.price,
    required this.finalPrice,
    required this.displayPrice,
    required this.discountPercentage,
    required this.discountAmount,
    required this.hasDiscount,
    this.image,
  });

  // Precio unitario que debe usar Flutter para mostrar
  double get currentPrice => hasDiscount ? displayPrice : price;

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final double originalPrice =
        double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;

    final double parsedFinalPrice =
        double.tryParse(json['final_price']?.toString() ?? '0') ?? 0.0;

    final double parsedDisplayPrice =
        double.tryParse(json['display_price']?.toString() ?? '0') ?? 0.0;

    final double parsedDiscountPercentage =
        double.tryParse(json['discount_percentage']?.toString() ?? '0') ?? 0.0;

    final double parsedDiscountAmount =
        double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0;

    final bool parsedHasDiscount =
        json['has_discount'] == true ||
        json['has_discount'] == 1 ||
        json['has_discount'] == '1' ||
        parsedDiscountAmount > 0;

    final double safeDisplayPrice = parsedDisplayPrice > 0
        ? parsedDisplayPrice
        : (parsedFinalPrice > 0 ? parsedFinalPrice : originalPrice);

    return OrderDetailModel(
      name: json['name'] ?? 'Producto',
      quantity: json['quantity'] ?? 1,
      price: originalPrice,
      finalPrice: parsedFinalPrice,
      displayPrice: safeDisplayPrice,
      discountPercentage: parsedDiscountPercentage,
      discountAmount: parsedDiscountAmount,
      hasDiscount: parsedHasDiscount,
      image: json['image'],
    );
  }
}
