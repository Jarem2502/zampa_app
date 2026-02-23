import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/order_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _orderService = OrderService();
  bool _isLoading = true;

  List<Map<String, dynamic>> _activeOrders = [];
  List<Map<String, dynamic>> _pastOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final rawOrders = await _orderService.getMyOrders();

    List<Map<String, dynamic>> active = [];
    List<Map<String, dynamic>> past = [];

    for (var order in rawOrders) {
      final mappedOrder = _mapOrderToUI(order);
      if (mappedOrder['isActive']) {
        active.add(mappedOrder);
      } else {
        past.add(mappedOrder);
      }
    }

    setState(() {
      _activeOrders = active;
      _pastOrders = past;
      _isLoading = false;
    });
  }

  // Traductor: Convierte los datos de Laravel a tu diseño UI
  Map<String, dynamic> _mapOrderToUI(dynamic orderData) {
    String rawStatus = orderData['status'] ?? 'validating';
    String statusUI;
    Color statusColor;
    bool isActive = true;

    // Asignamos colores según el estado de la base de datos
    switch (rawStatus) {
      case 'validating':
        statusUI = 'Validando Pago';
        statusColor = Colors.orange;
        break;
      case 'preparing':
        statusUI = 'En Preparación';
        statusColor = Colors.blue;
        break;
      case 'ready':
        statusUI = 'Listo para Entregar';
        statusColor = Colors.greenAccent.shade700;
        break;
      case 'delivered':
        statusUI = 'Entregado';
        statusColor = Colors.green;
        isActive = false;
        break;
      case 'cancelled':
        statusUI = 'Cancelado';
        statusColor = Colors.red;
        isActive = false;
        break;
      default:
        statusUI = 'Procesando';
        statusColor = Colors.grey;
    }

    // Formateamos la fecha simple (YYYY-MM-DD)
    String dateStr =
        orderData['created_at']?.toString().substring(0, 10) ?? 'Hoy';

    return {
      'id': '#${orderData['id'].toString().padLeft(4, '0')}',
      'date': dateStr,
      'items': _parseItems(orderData['products']),
      'total': double.tryParse(orderData['total'].toString()) ?? 0.0,
      'status': statusUI,
      'statusColor': statusColor,
      'type': orderData['order_type'] ?? 'Delivery',
      'isActive': isActive,
      'raw_id': orderData['id'], // ID real para enviar al tracking
    };
  }

  // Intenta leer el JSON de productos para mostrar un resumen
  String _parseItems(dynamic productsData) {
    if (productsData == null) return "Productos Zampa";
    try {
      List<dynamic> items = [];
      if (productsData is String) {
        items = jsonDecode(productsData);
      } else if (productsData is List) {
        items = productsData;
      }
      if (items.isEmpty) return "Productos de Zampa";

      List<String> names = [];
      for (var item in items) {
        int q = item['quantity'] ?? 1;
        // Si tienes el nombre guardado lo usa, si no, usa una genérica
        String name = item['name'] ?? item['nombre'] ?? 'Producto';
        names.add('${q}x $name');
      }
      return names.join(', ');
    } catch (e) {
      return "Productos en tu pedido";
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            "Mis Pedidos",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF81C784),
            indicatorWeight: 3,
            tabs: [
              Tab(text: "En Curso"),
              Tab(text: "Historial"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : TabBarView(
                children: [
                  _OrdersList(orders: _activeOrders, isActive: true),
                  _OrdersList(orders: _pastOrders, isActive: false),
                ],
              ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final bool isActive;

  const _OrdersList({required this.orders, required this.isActive});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              isActive
                  ? "No tienes pedidos en curso"
                  : "No tienes historial aún",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (isActive) {
                context.push(
                  '/tracking',
                  extra: {
                    'orderId': order['raw_id'], // Pasamos el ID real de SQL
                    'status': order['status'],
                  },
                );
              } else {
                context.push('/historial-detalle', extra: order);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order['id'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: (order['statusColor'] as Color).withOpacity(
                            0.1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order['status'],
                          style: TextStyle(
                            color: order['statusColor'],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    order['items'],
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order['date'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const Spacer(),
                      Text(
                        "S/${order['total'].toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  Row(
                    children: [
                      Icon(
                        order['type'].toString().toLowerCase().contains(
                              'llevar',
                            )
                            ? Icons.shopping_bag_outlined
                            : Icons.store,
                        size: 18,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        order['type'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Seguir Pedido",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        const Text(
                          "Detalles >",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
