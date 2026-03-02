class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final int categoryId;
  final bool isPromo;
  final double promoPrice;
  final String? promoName; // 🔥 NUEVO
  final String? promoStart; // 🔥 NUEVO
  final String? promoEnd; // 🔥 NUEVO

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.categoryId,
    this.isPromo = false,
    this.promoPrice = 0.0,
    this.promoName,
    this.promoStart,
    this.promoEnd,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    const String baseUrl = 'https://zampa.pro-cafes.com/storage/';
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Producto',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      categoryId: json['category_id'] ?? 1,
      imageUrl: json['image'] != null ? baseUrl + json['image'] : null,
      isPromo:
          json['is_promo'] == 1 ||
          json['is_promo'] == true ||
          json['is_promo'] == '1',
      promoPrice:
          double.tryParse(json['promo_price']?.toString() ?? '0') ?? 0.0,
      promoName: json['promo_name'],
      promoStart: json['promo_start'],
      promoEnd: json['promo_end'],
    );
  }
}
