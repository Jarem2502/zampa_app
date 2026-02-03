import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  final String currentStatus;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos los pasos del proceso dinámicamente según el estado real
    final steps = [
      {
        'title': 'Pedido Enviado',
        'desc': 'Hemos recibido tu solicitud y comprobante.',
        'isActive': true,
        'time': '2:30 PM'
      },
      {
        'title': 'Validando Pago',
        'desc': 'El administrador está revisando tu captura.',
        'isActive': currentStatus == 'Validando Pago' || currentStatus == 'En Preparación' || currentStatus == 'Listo',
        'time': '2:32 PM'
      },
      {
        'title': 'En Preparación',
        'desc': 'Tus alimentos se están cocinando.',
        'isActive': currentStatus == 'En Preparación' || currentStatus == 'Listo',
        'time': currentStatus == 'En Preparación' ? 'En curso' : '--:--'
      },
      {
        'title': 'Listo para Recoger',
        'desc': 'Acércate al mostrador o a tu mesa.',
        'isActive': currentStatus == 'Listo',
        'time': '--:--'
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Usamos context.pop() para regresar a la lista de pedidos
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Seguimiento $orderId", 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ILUSTRACIÓN DE ESTADO
            Center(
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.timer_outlined, size: 60, color: Colors.orange[400]),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Tiempo estimado: 15-20 min",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 40),

            // LÍNEA DE TIEMPO (Simplificada con Row y Column)
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
                    // --- INDICADOR VISUAL (Línea y Círculo) ---
                    Column(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green : Colors.grey[300],
                            shape: BoxShape.circle,
                            border: isActive ? Border.all(color: Colors.greenAccent, width: 3) : null,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 50, // Espacio entre pasos
                            color: isActive ? Colors.green : Colors.grey[300],
                          ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    
                    // --- TEXTOS DEL PASO ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                step['title'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isActive ? Colors.black : Colors.grey,
                                ),
                              ),
                              Text(
                                step['time'] as String,
                                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                              ),
                            ],
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
            
            // NOTIFICACIÓN FINAL
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.notifications_active, color: Colors.blue, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Te avisaremos por este medio cuando tu pedido esté listo.",
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}