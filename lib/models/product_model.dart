class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final int categoryId;
  final bool isPromo; // Para el panel admin (saber si está programada)
  final bool isActivePromo; // 🔥 NUEVO: Para saber si HOY está en oferta
  final double promoPrice;
  final String? promoName;
  final String? promoStart;
  final String? promoEnd;
  final bool isAvailable;
  final int stock;
  final int salesCount;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.categoryId,
    this.isPromo = false,
    this.isActivePromo = false, // 🔥
    this.promoPrice = 0.0,
    this.promoName,
    this.promoStart,
    this.promoEnd,
    this.isAvailable = true,
    this.stock = 999,
    this.salesCount = 0,
  });

  // 🔥 ATAJO INTELIGENTE: Nos da el precio final real de HOY automáticamente
  double get currentPrice => isActivePromo ? promoPrice : price;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    const String baseUrl = 'https://zampa.pro-cafes.com/storage/';
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Producto',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      categoryId: json['category_id'] ?? 1,
      imageUrl: json['image'] != null ? baseUrl + json['image'] : null,

      // Admin: ¿Está el switch prendido?
      isPromo:
          json['is_promo'] == 1 ||
          json['is_promo'] == true ||
          json['is_promo'] == '1',

      // Cliente: ¿La fecha es hoy?
      isActivePromo:
          json['is_active_promo'] == 1 ||
          json['is_active_promo'] == true ||
          json['is_active_promo'] == '1',

      promoPrice:
          double.tryParse(json['promo_price']?.toString() ?? '0') ?? 0.0,
      promoName: json['promo_name'],
      promoStart: json['promo_start'],
      promoEnd: json['promo_end'],
      isAvailable:
          json['is_available'] == 1 ||
          json['is_available'] == true ||
          json['is_available'] == '1',
      stock: json['stock'] ?? 999,
      salesCount: int.tryParse(json['sales_count']?.toString() ?? '0') ?? 0,
    );
  }
}
