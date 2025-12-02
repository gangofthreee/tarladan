import 'package:flutter/material.dart';
import 'farmer_create_ad.dart';
import 'farmer_all_ads.dart';
import 'farmer_ad_detail.dart';
import 'farmer_orders.dart';
import 'farmer_settings_page.dart';
import '../../services/user_service.dart';

import '../../widgets/themed_scaffold.dart';

class FarmerMainPage extends StatefulWidget {
  const FarmerMainPage({super.key});

  @override
  State<FarmerMainPage> createState() => _FarmerMainPageState();
}

class _FarmerMainPageState extends State<FarmerMainPage> {
  String _userName = 'Çiftçi';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await UserService.getUserFirstName();
    setState(() {
      _userName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: ThemedAppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Tarladan',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Merhaba, $_userName',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _buildInteractiveActionCard(
                    'Açık İlanlarım',
                    Icons.format_list_bulleted,
                    Color(0xFF00D563),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FarmerAllAds(),
                      ),
                    ),
                  ),
                  _buildInteractiveActionCard(
                    'Yeni İlan Aç',
                    Icons.add_circle_outline,
                    Color(0xFF00D563),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FarmerCreateAd(),
                      ),
                    ),
                  ),
                  _buildInteractiveActionCard(
                    'Siparişlerim',
                    Icons.inventory_2_outlined,
                    Color(0xFF00D563),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FarmerOrdersScreen(),
                      ),
                    ),
                  ),
                  _buildInteractiveActionCard(
                    'Ayarlar',
                    Icons.settings,
                    Color(0xFF00D563),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FarmerSettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Son İlanlar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              _buildProductItem(
                context,
                'Domates',
                '100 kg',
                '₺5/kg',
                'Aktif',
                true,
              ),
              SizedBox(height: 12),
              _buildProductItem(
                context,
                'Salatalık',
                '50 kg',
                '₺3/kg',
                'Aktif',
                true,
              ),
              SizedBox(height: 12),
              _buildProductItem(
                context,
                'Biber',
                '75 kg',
                '₺4/kg',
                'Beklemede',
                false,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  Widget _buildInteractiveActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Builder(
      builder: (context) => Material(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          splashColor: color.withOpacity(0.3),
          highlightColor: color.withOpacity(0.1),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: color),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(
    BuildContext context,
    String name,
    String amount,
    String price,
    String status,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FarmerAdDetail(productId: 0)),
        );
        // Bu sayfada statik veri olduğu için refresh gerekmez
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? Color(0xFF00D563) : Color(0xFFFF9500),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF00D563),
        unselectedItemColor: Colors.grey,
        elevation: 0,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted),
            label: 'İlanlarım',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Siparişler',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
        onTap: (index) {
          if (index == 0) {
            // Already on home page, do nothing
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FarmerAllAds()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FarmerOrdersScreen(),
              ),
            );
          } else if (index == 3) {
            // Navigate to settings page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FarmerSettingsPage(),
              ),
            );
          }
        },
      ),
    );
  }
}
