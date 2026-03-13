import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal {
    double currentPrice = product.isPromo ? product.promoPrice : product.price;
    return currentPrice * quantity;
  }
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += item.subtotal;
    }
    return total;
  }

  int get itemCount => _items.length;

  void addToCart(ProductModel product, {int quantity = 1}) {
    int index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      int newTotal = _items[index].quantity + quantity;
      // 🔥 Validamos silenciosamente contra el stock
      if (newTotal > product.stock) {
        _items[index].quantity = product.stock;
      } else {
        _items[index].quantity = newTotal;
      }
    } else {
      int finalQty = quantity > product.stock ? product.stock : quantity;
      _items.add(CartItem(product: product, quantity: finalQty));
    }
    notifyListeners();
  }

  void removeFromCart(CartItem targetItem) {
    _items.removeWhere((item) => item == targetItem);
    notifyListeners();
  }

  void updateQuantity(CartItem targetItem, int newQuantity) {
    int index = _items.indexOf(targetItem);
    if (index >= 0) {
      if (newQuantity <= 0) {
        removeFromCart(targetItem);
      } else if (newQuantity <= _items[index].product.stock) {
        _items[index].quantity = newQuantity;
        notifyListeners();
      } else {
        // 🔥 Si intentan pasarse del límite en el carrito
        _items[index].quantity = _items[index].product.stock;
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
