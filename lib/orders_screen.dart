import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  final _orderService = OrderService();
  bool _isLoading = true;
  late TabController _tabController;

  List<OrderModel> _activeOrders = [];
  List<OrderModel> _pastOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    final rawOrders = await _orderService.getMyOrders();

    List<OrderModel> active = [];
    List<OrderModel> past = [];

    for (var rawOrder in rawOrders) {
      final order = OrderModel.fromJson(rawOrder);
      // Clasificamos según el estado
      if (order.status == 'delivered' || order.status == 'cancelled') {
        past.add(order);
      } else {
        active.add(order);
      }
    }

    if (mounted) {
      setState(() {
        _activeOrders = active;
        _pastOrders = past;
        _isLoading = false;
      });
    }
  }

  // Utilidad para colores y textos
  Map<String, dynamic> _getStatusData(String status) {
    switch (status) {
      case 'validating':
        return {'text': 'Validando Pago', 'color': Colors.orange};
      case 'preparing':
        return {'text': 'Preparando', 'color': Colors.blue};
      case 'ready':
        return {'text': 'Listo para entregar', 'color': Colors.green};
      case 'delivered':
        return {'text': 'Entregado', 'color': Colors.grey};
      case 'cancelled':
        return {'text': 'Cancelado', 'color': Colors.red};
      default:
        return {'text': 'Pendiente', 'color': Colors.black};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: const Text(
          "Mis Pedidos",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: "En Curso"),
            Tab(text: "Historial"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(_activeOrders, isActive: true),
                _buildOrderList(_pastOrders, isActive: false),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, {required bool isActive}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isActive
                  ? "No tienes pedidos en curso"
                  : "Aún no tienes historial",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      color: Colors.black,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final order = orders[index];
          final statusData = _getStatusData(order.status);
          String formattedDate = '';
          try {
            final date = DateTime.parse(order.createdAt).toLocal();
            formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);
          } catch (e) {
            formattedDate = order.createdAt;
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CABECERA DEL PEDIDO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pedido #${order.id}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (statusData['color'] as Color).withOpacity(
                            0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusData['text'],
                          style: TextStyle(
                            color: statusData['color'],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formattedDate,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Modalidad: ${order.orderType}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🔥 LISTA DE PRODUCTOS DEL PEDIDO 🔥
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.items.isEmpty)
                          const Text(
                            "Detalle no disponible",
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          ...order.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${item.quantity}x",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    "S/${(item.price * item.quantity).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // TOTAL Y BOTÓN DE ACCIÓN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          Text(
                            "S/${order.total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (isActive) {
                            // Vamos al tracking
                            context.push(
                              '/tracking',
                              extra: {
                                'orderId': order.id,
                                'status': order.status,
                              },
                            );
                          } else {
                            // Vamos al detalle
                            context.push(
                              '/historial-detalle',
                              extra: {
                                'id': order.id,
                                'total': order.total,
                                'orderType': order.orderType,
                                'status': order.status,
                                'date': formattedDate,
                                'statusText': statusData['text'],
                                'statusColor': statusData['color'],
                                'items': order.items,
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive
                              ? Colors.black
                              : Colors.grey[100],
                          elevation: isActive ? 4 : 0,
                          shadowColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isActive ? "Seguir Pedido" : "Ver Detalle",
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
