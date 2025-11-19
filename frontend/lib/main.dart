import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/User/splash_screen.dart';
import 'screens/User/login_screen.dart';
import 'screens/User/signup_screen.dart';
import 'screens/Farmer/farmer_main_page.dart';
import 'screens/Farmer/farmer_orders.dart';
import 'screens/Warehouseman/warehouseman_main_page.dart';
import 'screens/Trucker/trucker_main_page.dart';
import 'screens/Customer/customer_main_page.dart';
import 'config/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Tarladan',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const LoginPage(), // Login page başlangıç
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
      },
    );
  }
}
