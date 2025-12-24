import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import '../../widgets/user_base_screen.dart';
import '../Farmer/farmer_main_page.dart';
import '../Trucker/trucker_main_page.dart';
import '../Warehouseman/warehouseman_main_page.dart';
import '../Customer/customer_main_page.dart';
import '../../utils/page_transitions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Minimum 1.5 saniye bekle (Splash görünsün)
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;

    final result = await AuthService.checkLoginStatus();
    
    if (!mounted) return;

    if (result.isSuccess && result.role != null) {
      Widget dest;
      switch (result.role) {
        case 'FARMER':
          dest = const FarmerMainPage();
          break;
        case 'TRUCKER':
          dest = const TruckerMainPage();
          break;
        case 'CUSTOMER':
          dest = const CustomerMainPage();
          break;
        case 'DEPOT_OWNER':
          dest = const WarehousemanMainPage();
          break;
        default:
          dest = const LoginPage();
      }
      AppNavigator.pushReplacement(context, dest, transition: TransitionType.fade);
    } else {
      AppNavigator.pushReplacement(context, const LoginPage(), transition: TransitionType.fade);
    }
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
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
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
