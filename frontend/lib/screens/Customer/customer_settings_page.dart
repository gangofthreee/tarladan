import 'package:flutter/material.dart';
import '../../widgets/base_settings_widget.dart';
import '../../widgets/customerW/customer_widgets.dart';

class CustomerSettingsPage extends StatelessWidget {
  const CustomerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsWidget(
      primaryColor: const Color(0xFF4CAF50),
      useGradientBackground: true,
      bottomNavigationBar: const CustomerBottomNavBar(currentIndex: 3),
    );
  }
}
