import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_zampa/services/pusher_config.dart';
import 'package:go_router/go_router.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;
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
  final PusherConfig _pusherConfig = PusherConfig();
  String _mensaje = "";
  Timer? _messageTimer;

  late String _status;
  int? _estimatedMinutes;
  final _orderService = OrderService();
  Timer? _timer;

  final List<Map<String, dynamic>> _steps = [
    {
      'status': 'validating',
      'title': 'Validando Pago',
      'desc': 'Estamos confirmando tu transferencia.',
      'icon': Icons.receipt_long,
    },
    {
      'status': 'preparing',
      'title': 'Preparando',
      'desc': 'La cocina está preparando tu pedido.',
      'icon': Icons.soup_kitchen,
    },
    {
      'status': 'ready',
      'title': 'Listo',
      'desc': 'Tu pedido está listo para entregar/recoger.',
      'icon': Icons.check_circle_outline,
    },
    {
      'status': 'delivered',
      'title': 'Entregado',
      'desc': '¡A disfrutar tu comida!',
      'icon': Icons.home,
    },
  ];

  @override
  void initState() {
    super.initState();

    _pusherConfig.initPusher(
      channelName: "zampa-tracking", // El canal para los pedidos
      eventName: "estado-actualizado", // El evento que lanzará Laravel
      onEventTriggered: (event) {
        if (!mounted) return;
        dynamic data;

        if (event.data is String) {
          data = jsonDecode(event.data.toString());
        } else {
          data = event.data;
        }

        // Aquí recibimos el texto (ej. "¡Tu hamburguesa ya está en camino!")
        String mensajeRecibido = data['mensaje'] ?? "Actualización de pedido";

        setState(() {
          _mensaje = mensajeRecibido;
        });

        _mostrarAlerta(mensajeRecibido);

        // 🔥 NUEVO TRUCO: Borrar el texto después de 6 segundos
        _messageTimer?.cancel(); // Cancelamos si había uno anterior
        _messageTimer = Timer(const Duration(seconds: 6), () {
          if (mounted) {
            setState(() {
              _mensaje = ""; // Lo vaciamos para que desaparezca de la pantalla
            });
          }
        });
      },
    );

    _status = widget.currentStatus;
    _fetchCurrentOrderData();
    _startTracking();
  }

  @override
  void dispose() {
    _pusherConfig.disconnect(); // Apagamos la escucha al salir
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchCurrentOrderData() async {
    final rawOrders = await _orderService.getMyOrders();
    try {
      final orderData = rawOrders.firstWhere(
        (o) => o['id'].toString() == widget.orderId.toString(),
      );
      final order = OrderModel.fromJson(orderData);

      if (mounted) {
        setState(() {
          _status = order.status;
          _estimatedMinutes = order.estimatedTime;
        });

        if (_status == 'delivered' || _status == 'cancelled') {
          _timer?.cancel();
        }
      }
    } catch (e) {
      // Usamos debugPrint para evitar la línea amarilla de avoid_print
      debugPrint("No se encontró el pedido actual en el historial.");
    }
  }

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchCurrentOrderData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_status == 'cancelled') {
      return _buildCancelledState();
    }

    int currentStepIndex = _steps.indexWhere((s) => s['status'] == _status);
    if (currentStepIndex == -1) currentStepIndex = 0;

    return Scaffold(
      backgroundColor: Colors.white,
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
        title: Text(
          "Pedido #${widget.orderId}",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_status == 'preparing' &&
                _estimatedMinutes != null &&
                _estimatedMinutes! > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.timer_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tiempo Estimado",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "~$_estimatedMinutes minutos",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const Text(
              "Estado de tu pedido",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            Text(_mensaje),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                bool isCompleted = index < currentStepIndex;
                bool isActive = index == currentStepIndex;
                bool isLast = index == _steps.length - 1;

                Color iconColor = isCompleted || isActive
                    ? Colors.black
                    : Colors.grey[300]!;
                Color lineColor = isCompleted
                    ? Colors.black
                    : Colors.grey[200]!;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.black
                                : (isCompleted
                                      ? Colors.grey[200]
                                      : Colors.white),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted || isActive
                                  ? Colors.black
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            step['icon'] as IconData,
                            color: isActive ? Colors.white : iconColor,
                            size: 24,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 3,
                            height: 60,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: lineColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['title'] as String,
                              style: TextStyle(
                                fontWeight: isActive
                                    ? FontWeight.w900
                                    : FontWeight.bold,
                                fontSize: 18,
                                color: isActive
                                    ? Colors.black
                                    : (isCompleted
                                          ? Colors.black87
                                          : Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              step['desc'] as String,
                              style: TextStyle(
                                color: isActive
                                    ? Colors.black54
                                    : (isCompleted
                                          ? Colors.black54
                                          : Colors.grey[400]),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
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

  Widget _buildCancelledState() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel_outlined,
                  size: 80,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Pedido Cancelado",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              const Text(
                "Lamentablemente tu pedido no pudo ser procesado o el pago no fue validado.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => context.go('/menu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Volver al Menú",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarAlerta(String contenido) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.fastfood, color: Color(0xFF1A9956)),
              SizedBox(width: 8),
              Text(
                "¡Aviso Zampa!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(contenido, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              child: const Text(
                "Genial",
                style: TextStyle(
                  color: Color(0xFF1A9956),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
