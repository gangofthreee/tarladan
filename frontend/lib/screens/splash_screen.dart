import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00C853), // Yeşil arka plan (#00C853 gibi)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Beyaz daire ve logo
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                // Logonunuzu assets klasöründen çağırın
                child: Image.asset(
                  'assets/logo.png', // Buraya logonuzun dosya yolunu koyun
                  width: 60,
                  height: 60,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // "tarladan" başlığı
            const Text(
              'tarladan',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Alt metin
            const Text(
              'Üreticiden Tüketiciye',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
