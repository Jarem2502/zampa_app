class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final int categoryId;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.categoryId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // 🔥 URL base para Hostinger
    const String baseUrl = 'https://zampa.pro-cafes.com/storage/';

    // Mapeo exacto según tu SQL
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Producto',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      categoryId: json['category_id'] ?? 1,
      // 🔥 En tu SQL la columna se llama 'image'
      imageUrl: json['image'] != null ? baseUrl + json['image'] : null,
    );
  }
}