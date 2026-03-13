import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Importación de modelos
import 'models/product_model.dart';

// Importación de providers (🔥 Agregamos ProductProvider)
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/product_provider.dart';

// Importación de pantallas (🔥 Cambiamos MenuScreen por HomeScreen)
import 'login_screen.dart';
import 'register_screen.dart';
import 'recovery_screens.dart';
import 'home_screen.dart'; // <-- Aquí está el cambio
import 'cart_screen.dart';
import 'product_detail_screen.dart';
import 'admin_login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_offer_manager_screen.dart';
import 'chatbot_screen.dart';
import 'checkout_screen.dart';
import 'completed_order_detail_screen.dart';
import 'order_tracking_screen.dart';
import 'orders_screen.dart';
import 'payment_upload_screen.dart';
import 'profile_screen.dart';
import 'invite_screen.dart';
import 'feedback_screen.dart';
import 'about_us_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ), // 🔥 Registramos el nuevo Provider
      ],
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),

    GoRoute(
      path: '/registro',
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: '/recuperar',
      builder: (context, state) => const RecoveryScreen(),
    ),
    GoRoute(
      path: '/verificacion',
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return VerificationScreen(email: email);
      },
    ),
    GoRoute(
      path: '/nueva-password',
      builder: (context, state) {
        final data = state.extra as Map<String, String>? ?? {};
        return NewPasswordScreen(
          email: data['email'] ?? '',
          code: data['code'] ?? '',
        );
      },
    ),

    // 🔥 Actualizamos la ruta para que apunte al nuevo HomeScreen
    GoRoute(path: '/menu', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/carrito', builder: (context, state) => const CartScreen()),

    GoRoute(
      path: '/detalle',
      builder: (context, state) {
        final product = state.extra as ProductModel;
        return ProductDetailScreen(product: product);
      },
    ),

    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin-offers',
      builder: (context, state) => const AdminOfferManagerScreen(),
    ),

    GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
    GoRoute(
      path: '/chatbot',
      builder: (context, state) => const ChatBotScreen(),
    ),
    GoRoute(
      path:
          '/profile', // Fíjate que el drawer llama a '/perfil', si usas '/profile' debes actualizar el drawer
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(path: '/invite', builder: (context, state) => const InviteScreen()),
    GoRoute(
      path: '/feedback',
      builder: (context, state) => const FeedbackScreen(),
    ),
    GoRoute(path: '/about', builder: (context, state) => const AboutUsScreen()),

    GoRoute(
      path: '/checkout',
      builder: (context, state) {
        final total = state.extra as double;
        return CheckoutScreen(totalAmount: total);
      },
    ),

    GoRoute(
      path: '/pago-comprobante',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return PaymentUploadScreen(
          totalAmount: data['total'],
          paymentMethod: data['metodo'].toString(),
          clientName: data['nombre'],
          extraData: data,
        );
      },
    ),

    GoRoute(
      path: '/tracking',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return OrderTrackingScreen(
          orderId: data['orderId'],
          currentStatus: data['status'],
        );
      },
    ),

    GoRoute(
      path: '/historial-detalle',
      builder: (context, state) {
        final order = state.extra as Map<String, dynamic>;
        return CompletedOrderDetailScreen(order: order);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zampa App',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.black, // 🔥 Ajustado al estilo Zampa
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        scaffoldBackgroundColor: Colors.black, // 🔥 Ajustado al estilo Zampa
      ),
    );
  }
}
