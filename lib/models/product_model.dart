import '../utils/dio_client.dart';

class ProductModel {
  final int id;
  final String name;
  final double price;
  final String imagePath;
  final String description;
  final String categoryName;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
    required this.categoryName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Laravel a veces manda los precios como string (ej. "19.00"), lo pasamos a double
    double parsedPrice = 0.0;
    if (json['price'] != null) {
      parsedPrice = double.tryParse(json['price'].toString()) ?? 0.0;
    }

    // Extraemos el nombre de la categoría (Laravel trae un objeto anidado por el 'with')
    String catName = 'Otros';
    if (json['category'] != null && json['category']['name'] != null) {
      catName = json['category']['name'];
    }

    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Sin nombre',
      price: parsedPrice,
      // Usamos el helper de DioClient para armar la ruta completa de la imagen
      imagePath: DioClient.getImageUrl(
        json['image']?.toString().replaceAll('\\', '/'),
      ),
      description:
          json['description'] ?? 'Delicioso producto preparado al momento.',
      categoryName: catName,
    );
  }
}
