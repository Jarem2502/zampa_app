import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Importante
import 'package:provider/provider.dart'; // NUEVO: Importamos Provider
import '../providers/cart_provider.dart'; // NUEVO: Tu cerebro del carrito
import '../models/product_model.dart'; // NUEVO: Tu modelo real

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isDeleteMode = false;

  @override
  Widget build(BuildContext context) {
    // AQUÍ OCURRE LA MAGIA: Nos conectamos al cerebro del carrito
    final cart = context.watch<CartProvider>();
    final cartItems = cart.items;

    // Si el carrito se vacía, salimos del modo eliminar automáticamente
    if (cartItems.isEmpty && _isDeleteMode) {
      // Usamos un pequeño delay para no romper el ciclo de dibujado de Flutter
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _isDeleteMode = false);
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Mi Pedido",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Solo mostramos el botón de basura si hay productos
          if (cartItems.isNotEmpty)
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
      body: cartItems.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                if (_isDeleteMode)
                  Container(
                    width: double.infinity,
                    color: Colors.red[50],
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Toca el icono de basura para quitar productos",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = cartItems[index]; // Extraemos el CartItem

                      return CartItemWidget(
                        product: item.product,
                        qty: item.quantity,
                        isDeleteMode: _isDeleteMode,
                        // Usamos las funciones de tu Provider en lugar de listas locales
                        onRemove: () => cart.removeFromCart(item.product.id),
                        onQtyChanged: (val) =>
                            cart.updateQuantity(item.product.id, val),
                      );
                    },
                  ),
                ),
                _buildOrderSummary(
                  cart.totalAmount,
                ), // Le pasamos el total del Provider
              ],
            ),
    );
  }

  Widget _buildOrderSummary(double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total a Pagar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Text(
                "S/${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isDeleteMode
                  ? null
                  : () => context.push('/checkout', extra: total),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _isDeleteMode ? "Termina de editar" : "Confirmar Pedido",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const Text(
            "Tu carrito está vacío",
            style: TextStyle(fontSize: 20, color: Colors.black54),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text(
              "Ir al Menú",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final ProductModel product; // CAMBIADO: Ahora usa tu modelo real
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
        border: isDeleteMode
            ? Border.all(color: Colors.red.shade100, width: 2)
            : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.fastfood, color: Colors.black45),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "S/${product.price.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
          if (isDeleteMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onRemove,
            )
          else
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => qty > 1 ? onQtyChanged(qty - 1) : onRemove(),
                ),
                Text(
                  '$qty',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => onQtyChanged(qty + 1),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
