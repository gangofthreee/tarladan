import 'package:flutter/material.dart';
import '../../widgets/base_settings_widget.dart';
import '../../widgets/trucker_widgets.dart';

class TruckerSettingsPage extends StatelessWidget {
  const TruckerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsWidget(
      primaryColor: const Color(0xFF4CAF50),
      useGradientBackground: true,
      bottomNavigationBar: const TruckerBottomNavBar(currentIndex: 3),
    );
  }
}
