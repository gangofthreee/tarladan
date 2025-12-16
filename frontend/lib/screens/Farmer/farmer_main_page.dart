import 'package:flutter/material.dart';
import 'farmer_create_ad.dart';
import 'farmer_all_ads.dart';
import 'farmer_ad_detail.dart';
import 'farmer_orders.dart';
import 'farmer_settings_page.dart';
import '../../services/user_service.dart';
import '../../config/api_config.dart';
import '../../services/token_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../widgets/themed_scaffold.dart';
import '../../widgets/notification_button.dart';

class FarmerMainPage extends StatefulWidget {
  const FarmerMainPage({super.key});

  @override
  State<FarmerMainPage> createState() => _FarmerMainPageState();
}

class _FarmerMainPageState extends State<FarmerMainPage> {
  String _userName = 'Çiftçi';
  List<dynamic> _products = [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchAllProducts();
  }

  Future<void> _loadUserName() async {
    final name = await UserService.getUserFirstName();
    setState(() {
      _userName = name;
    });
  }

  Future<void> _fetchAllProducts() async {
    setState(() => _isLoadingProducts = true);

    try {
      final token = await TokenService.getAccessToken();
      if (token == null) {
        throw Exception('Token bulunamadı');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/farmer/product/all_products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          // Son eklenen ürünler önce gelsin diye ters çevir
          _products = data.reversed.toList();
          _isLoadingProducts = false;
        });
      } else {
        throw Exception('Ürünler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Ürünler yüklenirken hata: $e');
      setState(() => _isLoadingProducts = false);
    }
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
          const NotificationButton(),
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
                    () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FarmerCreateAd(),
                        ),
                      );
                      _fetchAllProducts(); // Geri dönüldüğünde listeyi yenile
                    },
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
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: 16),
              _isLoadingProducts
                  ? Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                  ? Center(
                      child: Text(
                        'Henüz ürün eklenmemiş',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Column(
                      children: _products.map((product) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: _buildProductItem(
                            context,
                            product['name'] ?? 'Ürün',
                            '${product['quantity_kg'] ?? 0} kg',
                            '₺${product['price_per_kg'] ?? 0}/kg',
                            'Aktif',
                            true,
                            product['id'],
                          ),
                        );
                      }).toList(),
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
    int productId,
  ) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FarmerAdDetail(productId: productId),
          ),
        );
        _fetchAllProducts(); // Geri dönüldüğünde listeyi yenile
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
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
                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
