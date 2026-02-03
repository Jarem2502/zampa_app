import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final activeOrders = [
      {
        'id': '#00125',
        'date': 'Hoy, 2:30 PM',
        'items': '1x Club Sándwich, 2x Frappé',
        'total': 45.90,
        'status': 'Validando Pago', 
        'statusColor': Colors.orange,
        'type': 'Para llevar',
      },
    ];

    final pastOrders = [
      {
        'id': '#00102',
        'date': 'Ayer, 1:00 PM',
        'items': '1x Hamburguesa Royal\n1x Gaseosa 500ml',
        'total': 22.50,
        'status': 'Entregado',
        'statusColor': Colors.green,
        'type': 'Comer en tienda',
      },
    ];

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
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
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
        body: TabBarView(
          children: [
            _OrdersList(orders: activeOrders, isActive: true),
            _OrdersList(orders: pastOrders, isActive: false),
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
              isActive ? "No tienes pedidos en curso" : "No tienes historial aún",
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (isActive) {
                context.push('/tracking', extra: {
                  'orderId': order['id'],
                  'status': order['status'],
                });
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
                      Text(order['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: (order['statusColor'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order['status'],
                          style: TextStyle(
                            color: order['statusColor'], 
                            fontWeight: FontWeight.bold, 
                            fontSize: 12
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
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(order['date'], style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const Spacer(),
                      Text("S/${order['total'].toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  Row(
                    children: [
                      Icon(
                        order['type'] == 'Para llevar' ? Icons.shopping_bag_outlined : Icons.store,
                        size: 18, color: Colors.black54
                      ),
                      const SizedBox(width: 6),
                      Text(order['type'], style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      const Spacer(),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text("Seguir Pedido", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      else
                        const Text(
                          "Detalles de la compra >",
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}