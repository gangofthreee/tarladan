import 'package:flutter/material.dart';
import '../../widgets/themed_scaffold.dart';
import 'farmer_settings_page.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  _FarmerOrdersScreenState createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  bool showActiveOrders = true;

  @override
  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: ThemedAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Siparişlerim',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildOrderCard(
                  productName: 'Tomato 500kg',
                  buyer: 'Migros',
                  status: 'Beklemede',
                  statusColor: Color(0xFFFFF4E6),
                  statusTextColor: Color(0xFFFF9500),
                  date: '12.05.2024',
                  icon: Icons.more_horiz,
                  iconColor: Colors.grey[400]!,
                ),
                SizedBox(height: 12),
                _buildOrderCard(
                  productName: 'Potato 1000kg',
                  buyer: 'Carrefour',
                  status: 'Onaylandı',
                  statusColor: Color(0xFFE6F7ED),
                  statusTextColor: Color(0xFF00D563),
                  date: '11.05.2024',
                  icon: Icons.store,
                  iconColor: Colors.grey[400]!,
                ),
                SizedBox(height: 12),
                _buildOrderCard(
                  productName: 'Cucumber 300kg',
                  buyer: 'BIM',
                  status: 'Yolda',
                  statusColor: Color(0xFFE3F2FD),
                  statusTextColor: Color(0xFF2196F3),
                  date: '10.05.2024',
                  icon: Icons.local_shipping,
                  iconColor: Colors.grey[400]!,
                ),
                SizedBox(height: 12),
                _buildOrderCard(
                  productName: 'Onion 750kg',
                  buyer: 'A101',
                  status: 'Teslim Edildi',
                  statusColor: Color(0xFFF5F5F5),
                  statusTextColor: Color(0xFF9E9E9E),
                  date: '09.05.2024',
                  icon: Icons.check_circle,
                  iconColor: Colors.grey[400]!,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showActiveOrders = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: showActiveOrders
                            ? Color(0xFF00D563)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: showActiveOrders
                              ? Color(0xFF00D563)
                              : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Aktif Siparişler',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: showActiveOrders ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showActiveOrders = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: !showActiveOrders
                            ? Color(0xFFE8E8E8)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !showActiveOrders
                              ? Color(0xFFE8E8E8)
                              : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Geçmiş Siparişler',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, 2),
    );
  }

  Widget _buildOrderCard({
    required String productName,
    required String buyer,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    required String date,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  productName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Alıcı: ',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                buyer,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusTextColor,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text(
                date,
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
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
        onTap: (index) {
          if (index == 0) {
            // Navigate to home (FarmerMainPage)
            Navigator.pop(context);
          } else if (index == 1) {
            // Navigate to ads page
            Navigator.pop(context);
          } else if (index == 2) {
            // Already on orders page, do nothing
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
      ),
    );
  }
}
