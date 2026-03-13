import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  ProductProvider() {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners(); // Avisamos a la UI que estamos cargando

    try {
      _products = await _productService.getProducts();
    } catch (e) {
      print("Error cargando productos: $e");
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners(); // Avisamos a la UI que ya terminamos
    }
  }
}
