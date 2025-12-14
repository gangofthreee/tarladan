import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../services/token_service.dart';
import 'customer_viewOrderDetail_page.dart';

import '../../widgets/themed_scaffold.dart';

class CustomerViewOrdersPage extends StatefulWidget {
  const CustomerViewOrdersPage({super.key});

  @override
  State<CustomerViewOrdersPage> createState() => _CustomerViewOrdersPageState();
}

class _CustomerViewOrdersPageState extends State<CustomerViewOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  // Örnek sipariş verileri (fallback)
  final List<Map<String, dynamic>> activeOrders = [
    {
      'productName': 'Domates',
      'quantity': '500kg',
      'seller': 'Çiftçi Emre',
      'date': '12.08.2023',
      'status': 'Onaylandı',
      'statusColor': Color(0xFF4CAF50),
      'image':
          'https://images.unsplash.com/photo-1546470427-227e4c84d1da?w=400',
    },
    {
      'productName': 'Patates',
      'quantity': '1000kg',
      'seller': 'Çiftçi Ayşe',
      'date': '10.08.2023',
      'status': 'Yolda',
      'statusColor': Color(0xFF2196F3),
      'image':
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400',
    },
  ];

  final List<Map<String, dynamic>> pastOrders = [
    {
      'productName': 'Soğan',
      'quantity': '200kg',
      'seller': 'Çiftçi Mehmet',
      'date': '08.08.2023',
      'status': 'Teslim Edildi',
      'statusColor': Color(0xFF4CAF50),
      'image':
          'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=400',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authHeaders = await TokenService.getAuthHeaders();
      print('🛒 Fetching orders from: ${ApiConfig.getCustomerOrdersUrl}');
      final response = await http.get(
        Uri.parse(ApiConfig.getCustomerOrdersUrl),
        headers: authHeaders,
      );

      print('🛒 Orders Response Status: ${response.statusCode}');
      print('🛒 Orders Response Body: ${response.body}');

      // Yeni token varsa güncelle
      await TokenService.checkAndUpdateToken(response);

      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = jsonDecode(response.body);
        setState(() {
          _orders = ordersJson
              .map((order) => order as Map<String, dynamic>)
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Siparişler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Orders fetch error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: ThemedAppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Siparişlerim',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF4CAF50),
              indicatorWeight: 3,
              labelColor: const Color(0xFF4CAF50),
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              tabs: const [
                Tab(text: 'Aktif Siparişler'),
                Tab(text: 'Geçmiş Siparişler'),
              ],
            ),
          ),

          // Tab Bar View
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Active Orders - API'den gelen PENDING siparişler
                      _buildOrderList(
                        _orders.where((o) => o['status'] == 'PENDING').toList(),
                      ),

                      // Past Orders - API'den gelen COMPLETED siparişler
                      _buildOrderList(
                        _orders.where((o) => o['status'] != 'PENDING').toList(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz sipariş yok',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    // API response formatını parse et
    final productName = order['productName'] ?? 'Ürün';
    final quantity = '${order['quantityKg'] ?? 0}kg';
    final locFrom = order['locFrom'] ?? '';
    final locTo = order['locTo'] ?? '';
    final totalPrice = order['totalPrice'] ?? 0;
    final status = order['status'] ?? 'PENDING';

    // Status'e göre renk ve metin
    Color statusColor;
    String statusText;
    if (status == 'PENDING') {
      statusColor = const Color(0xFFFFA726);
      statusText = 'Beklemede';
    } else if (status == 'COMPLETED') {
      statusColor = const Color(0xFF4CAF50);
      statusText = 'Tamamlandı';
    } else {
      statusColor = const Color(0xFF2196F3);
      statusText = status;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CustomerViewOrderDetailPage(orderId: order['id'] ?? 0),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Container(
                width: 120,
                height: 160,
                color: Colors.grey[200],
                child: Container(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 50,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ),

            // Order Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$productName $quantity',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Toplam: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${totalPrice}₺',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$locFrom → $locTo',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            status == 'PENDING'
                                ? Icons.access_time
                                : Icons.check_circle,
                            size: 16,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
