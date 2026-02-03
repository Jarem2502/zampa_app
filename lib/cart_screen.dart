import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Importante
import 'zampa_data.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isDeleteMode = false;

  // Datos de prueba (Luego esto vendrá de un Provider o Bloc)
  List<Map<String, dynamic>> myCart = [
    {
      'product': allProducts.firstWhere((p) => p.name.contains('Club Sándwich'), orElse: () => allProducts.first),
      'qty': 1,
    },
    {
      'product': allProducts.firstWhere((p) => p.name.contains('Hamburguesa Royal'), orElse: () => allProducts.first),
      'qty': 2,
    },
  ];

  double get total {
    double t = 0;
    for (var item in myCart) {
      Product p = item['product'];
      int qty = item['qty'];
      t += (p.price * qty);
    }
    return t;
  }

  void _removeItem(int index) {
    setState(() {
      myCart.removeAt(index);
      if (myCart.isEmpty) _isDeleteMode = false;
    });
  }

  void _updateQty(int index, int newQty) {
    setState(() {
      myCart[index]['qty'] = newQty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(), // CAMBIO: GoRouter pop
        ),
        title: const Text(
          "Mi Pedido",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDeleteMode ? Icons.check_circle : Icons.delete_outline,
              color: _isDeleteMode ? Colors.green : Colors.red,
            ),
            onPressed: () => setState(() => _isDeleteMode = !_isDeleteMode),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: myCart.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                if (_isDeleteMode)
                  Container(
                    width: double.infinity,
                    color: Colors.red[50],
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Toca 'Eliminar' para quitar productos",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: myCart.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = myCart[index];
                      return CartItemWidget(
                        product: item['product'],
                        qty: item['qty'],
                        isDeleteMode: _isDeleteMode,
                        onRemove: () => _removeItem(index),
                        onQtyChanged: (val) => _updateQty(index, val),
                      );
                    },
                  ),
                ),
                _buildOrderSummary(),
              ],
            ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total a Pagar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Text("S/${total.toStringAsFixed(2)}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isDeleteMode 
                ? null 
                : () => context.push('/checkout', extra: total), // CAMBIO: Enviar total a checkout
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _isDeleteMode ? "Termina de editar" : "Confirmar Pedido",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
          const Text("Tu carrito está vacío", style: TextStyle(fontSize: 20, color: Colors.black54)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text("Ir al Menú"),
          )
        ],
      ),
    );
  }
}

// Mantenemos tu CartItemWidget igual pero asegúrate de que use las clases correctas.
class CartItemWidget extends StatelessWidget {
  final Product product;
  final int qty;
  final bool isDeleteMode;
  final VoidCallback onRemove;
  final Function(int) onQtyChanged;

  const CartItemWidget({
    super.key,
    required this.product,
    required this.qty,
    required this.isDeleteMode,
    required this.onRemove,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDeleteMode ? Border.all(color: Colors.red.shade100, width: 2) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Icon(product.category == 'Bebidas' ? Icons.local_cafe : Icons.fastfood, color: Colors.black45),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("S/${product.price.toStringAsFixed(2)}", style: const TextStyle(color: Colors.green)),
              ],
            ),
          ),
          if (isDeleteMode)
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onRemove)
          else
            Row(
              children: [
                IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => qty > 1 ? onQtyChanged(qty - 1) : null),
                Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => onQtyChanged(qty + 1)),
              ],
            ),
        ],
      ),
    );
  }
}