import 'package:flutter/material.dart';
import '../models/product_model.dart';

// 1. Definimos cómo se ve un producto dentro del carrito (con su cantidad)
class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

// 2. El "Cerebro" que controlará todo el carrito en la app
class CartProvider with ChangeNotifier {
  // Lista secreta de los items en el carrito
  final List<CartItem> _items = [];

  // Función para que el resto de la app pueda leer qué hay en el carrito
  List<CartItem> get items => _items;

  // Calcula el precio total de todo el carrito
  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += item.subtotal;
    }
    return total;
  }

  // Cuenta cuántos productos diferentes hay
  int get itemCount => _items.length;

  // --- ACCIONES DEL CARRITO ---

  // Agregar un producto
  void addToCart(ProductModel product, {int quantity = 1}) {
    // Verificamos si el producto ya está en el carrito
    int index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      // Si ya existe, solo le sumamos la cantidad
      _items[index].quantity += quantity;
    } else {
      // Si no existe, lo metemos como nuevo
      _items.add(CartItem(product: product, quantity: quantity));
    }
    // ¡Avisa a toda la app que el carrito cambió para que se actualicen las pantallas!
    notifyListeners();
  }

  // Quitar un producto por completo
  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // Cambiar la cantidad (+ o -)
  void updateQuantity(int productId, int newQuantity) {
    int index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        removeFromCart(productId); // Si llega a 0, lo borramos
      } else {
        _items[index].quantity = newQuantity;
        notifyListeners();
      }
    }
  }

  // Vaciar todo el carrito (cuando el pedido se complete)
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
