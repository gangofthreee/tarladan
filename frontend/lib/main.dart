import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/Farmer/farmer_main_page.dart';
import 'screens/Farmer/farmer_orders.dart';
import 'screens/Warehouseman/warehouseman_main_page.dart';
import 'screens/Trucker/trucker_main_page.dart';
import 'screens/Customer/customer_main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarladan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const CustomerMainPage(), // Customer main page başlangıç
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterScreen(),
        '/farmer-main': (context) => const FarmerMainPage(),
        '/farmer-orders': (context) => const FarmerOrdersScreen(),
        '/warehouseman-main': (context) => const WarehousemanMainPage(),
        '/trucker-main': (context) => const TruckerMainPage(),
        '/customer-main': (context) => const CustomerMainPage(),
      },
    );
  }
}
