import 'package:flutter/material.dart';
import 'trucker_truckSaving_page.dart';
import 'trucker_create_ad.dart';
import 'trucker_truckList_page.dart';
import 'trucker_listAds_page.dart';
import 'trucker_settings_page.dart';
import '../../services/user_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/trucker_widgets.dart';

class TruckerMainPage extends StatefulWidget {
  const TruckerMainPage({super.key});
  @override
  State<TruckerMainPage> createState() => _TruckerMainPageState();
}

class _TruckerMainPageState extends State<TruckerMainPage> {
  int _selectedIndex = 0;
  String _userName = 'Nakliyeci';
  final _jobOffers = [
    {
      'route': 'İstanbul - Ankara',
      'price': '1500 TL',
      'icon': Icons.local_shipping,
    },
    {
      'route': 'Ankara - İzmir',
      'price': '1200 TL',
      'icon': Icons.local_shipping,
    },
  ];
  final _actionCards = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _actionCards.addAll([
      {
        'icon': Icons.local_shipping,
        'emoji': '🚛',
        'title': 'Kayıtlı Araçlarım',
        'page': const TruckerTruckListPage(),
      },
      {
        'icon': Icons.campaign,
        'emoji': '📢',
        'title': 'İlanlarım',
        'page': const TruckerListAdsPage(),
      },
      {
        'icon': Icons.assignment,
        'emoji': '📋',
        'title': 'Tır Kaydet',
        'page': const TruckerTruckSavingPage(),
      },
      {
        'icon': Icons.add_circle_outline,
        'emoji': '➕',
        'title': 'Yeni İlan Aç',
        'page': const TruckerCreateAdPage(),
      },
    ]);
  }

  Future<void> _loadUserName() async {
    final name = await UserService.getUserFirstName();
    setState(() => _userName = name);
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TruckerSettingsPage()),
      );
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TruckerMainHeader(userName: _userName),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: _actionCards
                      .map(
                        (card) => TruckerActionCard(
                          icon: card['icon'],
                          emoji: card['emoji'],
                          title: card['title'],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => card['page'],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Açık İş Teklifleri',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ..._jobOffers.map((job) => TruckerJobOfferCard(job: job)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: TruckerBottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
