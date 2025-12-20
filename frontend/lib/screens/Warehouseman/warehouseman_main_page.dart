import 'package:flutter/material.dart';
import 'warehouseman_myWarehouse_page.dart';
import 'warehouseman_createWarehouse_page.dart';
import 'warehouseman_settings_page.dart';
import '../../services/user_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/notification_button.dart';
import '../../widgets/warehouse_main_widgets.dart';
import '../../widgets/custom_bottom_navbar.dart';
import '../../utils/page_transitions.dart';

class WarehousemanMainPage extends StatefulWidget {
  const WarehousemanMainPage({super.key});
  @override
  State<WarehousemanMainPage> createState() => _WarehousemanMainPageState();
}

class _WarehousemanMainPageState extends State<WarehousemanMainPage> {
  int _idx = 0;
  String _name = 'Depocu';

  @override
  void initState() { 
    super.initState(); 
    UserService.getUserFirstName().then((n) { 
      print('DEBUG: Fetched Name for Main Page: $n');
      if (mounted) setState(() => _name = n); 
    }); 
  }

  void _tap(int i) {
    if (i == 3) AppNavigator.push(context, const WarehousemanSettingsPage(), transition: TransitionType.slideRight);
    else if (i == 0) setState(() => _idx = i);
    else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geliştirme Aşamasında'), duration: Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      useGradientBackground: true,
      appBar: ThemedAppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Tarladan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [NotificationButton()],
      ),
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20),
        WarehouseHeader(userName: _name),
        const SizedBox(height: 30),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [
          WarehouseMenuButton(label: 'Mevcut Depolarım', icon: Icons.warehouse, isPrimary: true, onPressed: () => AppNavigator.push(context, const WarehousemanMyWarehousePage(), transition: TransitionType.slideRight)),
          const SizedBox(height: 16),
          WarehouseMenuButton(label: 'Depo Ekle', icon: Icons.add_business, isPrimary: false, onPressed: () => AppNavigator.push(context, const WarehousemanCreateWarehousePage(depoOwnerId: 1), transition: TransitionType.slideRight)),
        ])),
      ])),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: _idx, onTap: _tap, items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Siparişler'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Cüzdan'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
      ]),
    );
  }
}
