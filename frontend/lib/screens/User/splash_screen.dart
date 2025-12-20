import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';
import '../../widgets/user_base_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to login screen after 2 seconds
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return UserBaseScreen(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Beyaz daire ve logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                // Using an icon instead of missing logo.png asset
                child: Icon(Icons.agriculture, size: 60, color: Color(0xFF3A5A40)),
              ),
            ),
            const SizedBox(height: 24),
            // "tarladan" başlığı
            const Text(
              'tarladan',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A5A40),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            // Alt metin
            Text(
              'Üreticiden Tüketiciye',
              style: TextStyle(
                fontSize: 18,
                color: const Color(0xFF3A5A40).withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
