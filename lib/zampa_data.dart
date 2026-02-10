class Product {
  final String name;
  final double price;
  final String description;
  final String category;    
  final String subCategory; 
  final String imagePath;   

  const Product({
    required this.name,
    required this.price,
    this.description = '',
    required this.category,
    required this.subCategory,
    this.imagePath = '', 
  });
}

// Lista vacía. Se llenará automáticamente con la API.
List<Product> allProducts = [];