import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/themed_scaffold.dart';
import '../../config/api_config.dart';
import '../../services/token_service.dart';
import 'farmer_settings_page.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  _FarmerOrdersScreenState createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  bool showActiveOrders = true;
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authHeaders = await TokenService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.getFarmerOrdersUrl),
        headers: authHeaders,
      );

      await TokenService.checkAndUpdateToken(response);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _orders = data is List ? data : [data];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Siparişler yüklenemedi: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Bağlantı hatası: $e';
        _isLoading = false;
      });
    }
  }

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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(_errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchOrders,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  )
                : _orders.isEmpty
                ? const Center(child: Text('Henüz sipariş yok'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildOrderCard(
                          productName: order['productName'] ?? 'Ürün',
                          buyer: order['customerName'] ?? 'Müşteri',
                          status: order['status'] ?? 'Beklemede',
                          statusColor: const Color(0xFFFFF4E6),
                          statusTextColor: const Color(0xFFFF9500),
                          date: order['orderDate'] ?? '',
                          icon: Icons.more_horiz,
                          iconColor: Colors.grey[400]!,
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
                            : Theme.of(context).cardColor,
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
                          color: showActiveOrders
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
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
                            ? (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800]
                                  : Color(0xFFE8E8E8))
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !showActiveOrders
                              ? (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[800]!
                                    : Color(0xFFE8E8E8))
                              : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Geçmiş Siparişler',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
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
