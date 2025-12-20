import 'package:flutter/material.dart';
import '../../widgets/base_settings_widget.dart';
import '../../widgets/custom_bottom_navbar.dart';

class WarehousemanSettingsPage extends StatelessWidget {
  const WarehousemanSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsWidget(
      primaryColor: const Color(0xFF4CAF50),
      useGradientBackground: true,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        onTap: (index) => _handleNavTap(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Siparişler'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Cüzdan'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
      ),
    );
  }

  void _handleNavTap(BuildContext context, int index) {
    if (index == 3) return; // Already on settings
    if (index == 0) {
      Navigator.popUntil(context, (r) => r.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geliştirme Aşamasında'), duration: Duration(seconds: 1)));
    }
  }
}
