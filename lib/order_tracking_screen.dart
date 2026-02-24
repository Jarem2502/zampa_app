import 'dart:async'; // Necesario para el Timer
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/order_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final dynamic orderId; // Cambiamos a dynamic para evitar errores de tipo int/string
  final String currentStatus;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.currentStatus,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late String _status;
  final _orderService = OrderService();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _status = widget.currentStatus;
    // 🔥 Iniciamos el seguimiento automático cada 10 segundos
    _startTracking();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Importante cancelar el timer al salir de la pantalla
    super.dispose();
  }

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final orders = await _orderService.getMyOrders();
      // Buscamos nuestro pedido específico en la lista para ver si cambió de estado
      final currentOrder = orders.firstWhere(
        (o) => o['id'].toString() == widget.orderId.toString(),
        orElse: () => null,
      );

      if (currentOrder != null && currentOrder['status'] != _status) {
        if (mounted) {
          setState(() {
            _status = currentOrder['status'];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Traducimos los estados técnicos a los de la UI
    final steps = [
      {
        'title': 'Pedido Enviado',
        'desc': 'Hemos recibido tu solicitud y comprobante.',
        'isActive': true,
      },
      {
        'title': 'Validando Pago',
        'desc': 'El administrador está revisando tu captura.',
        'isActive': _status == 'validating' || _status == 'preparing' || _status == 'ready',
      },
      {
        'title': 'En Preparación',
        'desc': 'Tus alimentos se están cocinando.',
        'isActive': _status == 'preparing' || _status == 'ready',
      },
      {
        'title': 'Listo para Recoger',
        'desc': 'Acércate al mostrador o a tu mesa.',
        'isActive': _status == 'ready',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Seguimiento #${widget.orderId}", 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Container(
                height: 120, width: 120,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _status == 'ready' ? Icons.check_circle : Icons.restaurant, 
                  size: 60, color: Colors.green
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                _status == 'ready' ? "¡Tu pedido está listo!" : "Tiempo estimado: 15-20 min",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 40),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                bool isActive = step['isActive'] as bool;
                bool isLast = index == steps.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 18, height: 18,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green : Colors.grey[300],
                            shape: BoxShape.circle,
                            border: isActive ? Border.all(color: Colors.greenAccent, width: 3) : null,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2, height: 50,
                            color: isActive ? Colors.green : Colors.grey[300],
                          ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15,
                              color: isActive ? Colors.black : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step['desc'] as String,
                            style: TextStyle(
                              color: isActive ? Colors.black54 : Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 30), 
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}