import 'dart:io';
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

// ⚠️ SADECE GELİŞTİRME İÇİN: Self-signed sertifikaları kabul et
// Production'da bu kodu KALDIR veya const bool kDebugMode kontrolü ekle
class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  // Development için SSL sertifika doğrulamasını atla
  // ⚠️ Production build'de bu satırı yoruma al veya kDebugMode kontrolü ekle
  HttpOverrides.global = DevHttpOverrides();

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
          home: const SplashScreen(), // Splash screen başlangıç
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
