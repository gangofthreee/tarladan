import 'package:flutter/material.dart';
import 'trucker_truckSaving_page.dart';
import 'trucker_create_ad.dart';
import 'trucker_truckList_page.dart';
import 'trucker_listAds_page.dart';
import 'trucker_settings_page.dart';

import '../../widgets/themed_scaffold.dart';
class TruckerMainPage extends StatefulWidget {
  const TruckerMainPage({super.key});

  @override
  State<TruckerMainPage> createState() => _TruckerMainPageState();
}

class _TruckerMainPageState extends State<TruckerMainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 3) {
      // Ayarlar sayfasına git
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TruckerSettingsPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Örnek açık iş teklifleri
  final List<Map<String, dynamic>> jobOffers = [
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

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with notification
              Container(
                padding: const EdgeInsets.all(20),
                color: Theme.of(context).cardColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tarladan',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        size: 28,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Welcome Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Merhaba, Ahmet',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Action Cards Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildActionCard(
                      icon: Icons.local_shipping,
                      emoji: '🚛',
                      title: 'Kayıtlı Araçlarım',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TruckerTruckListPage(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      icon: Icons.campaign,
                      emoji: '📢',
                      title: 'İlanlarım',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TruckerListAdsPage(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      icon: Icons.assignment,
                      emoji: '📋',
                      title: 'Tır Kaydet',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TruckerTruckSavingPage(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      icon: Icons.add_circle_outline,
                      emoji: '➕',
                      title: 'Yeni İlan Aç',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TruckerCreateAdPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Açık İş Teklifleri Section
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

              // Job Offers List
              ...jobOffers.map((job) => _buildJobOfferCard(job)),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
                    selectedItemColor: const Color(0xFF4CAF50),
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping),
              label: 'İş Teklifleri',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Siparişler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Ayarlar',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String emoji,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobOfferCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Truck Icon
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(job['icon'], size: 36, color: Colors.grey[700]),
          ),

          const SizedBox(width: 16),

          // Job Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['route'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  job['price'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),

          // Action Button
          ElevatedButton(
            onPressed: () {
              // Handle bid action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Teklif Ver',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
