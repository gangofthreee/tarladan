import 'package:flutter/material.dart';
import 'trucker_truckSaving_page.dart';
import 'trucker_create_ad.dart';
import 'trucker_truckList_page.dart';
import 'trucker_listAds_page.dart';
import 'trucker_settings_page.dart';
import '../../services/user_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/trucker_widgets.dart';
import '../../widgets/custom_bottom_navbar.dart';
import '../../widgets/notification_button.dart';

class TruckerMainPage extends StatefulWidget {
  const TruckerMainPage({super.key});
  @override
  State<TruckerMainPage> createState() => _TruckerMainPageState();
}

class _TruckerMainPageState extends State<TruckerMainPage> {
  int _selectedIndex = 0;
  String _userName = 'Nakliyeci';
  final _jobOffers = [
    {'route': 'İstanbul - Ankara', 'price': '1500 TL', 'icon': Icons.local_shipping},
    {'route': 'Ankara - İzmir', 'price': '1200 TL', 'icon': Icons.local_shipping},
  ];
  final _actionCards = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _actionCards.addAll([
      {'emoji': '🚛', 'title': 'Kayıtlı Araçlarım', 'page': const TruckerTruckListPage()},
      {'emoji': '📢', 'title': 'İlanlarım', 'page': const TruckerListAdsPage()},
      {'emoji': '📋', 'title': 'Tır Kaydet', 'page': const TruckerTruckSavingPage()},
      {'emoji': '➕', 'title': 'Yeni İlan Aç', 'page': const TruckerCreateAdPage()},
    ]);
  }

  Future<void> _loadUserName() async {
    final name = await UserService.getUserFirstName();
    setState(() => _userName = name);
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TruckerSettingsPage()));
    } else if (index == 1 || index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gelişme Aşamasında'), duration: Duration(seconds: 2)));
    } else {
      setState(() => _selectedIndex = index);
    }
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(height: 16),
            TruckerMainHeader(userName: _userName),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.1,
                children: _actionCards.map((c) => TruckerActionCard(emoji: c['emoji'], title: c['title'],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => c['page'])))).toList(),
              ),
            ),
            const SizedBox(height: 30),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('İş Tekliflerim', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]))),
            const SizedBox(height: 16),
            ..._jobOffers.map((job) => TruckerJobOfferCard(job: job)),
            const SizedBox(height: 30),
          ]),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'İş Teklifleri'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Siparişler'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
      ),
    );
  }
}
