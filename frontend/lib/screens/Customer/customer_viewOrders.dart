import 'package:flutter/material.dart';
import 'customer_viewOrderDetail_page.dart';

class CustomerViewOrdersPage extends StatefulWidget {
  const CustomerViewOrdersPage({super.key});

  @override
  State<CustomerViewOrdersPage> createState() => _CustomerViewOrdersPageState();
}

class _CustomerViewOrdersPageState extends State<CustomerViewOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Örnek sipariş verileri
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Siparişlerim',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active Orders
                _buildOrderList(activeOrders),

                // Past Orders
                _buildOrderList(pastOrders),
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerViewOrderDetailPage(
              productName: order['productName'],
              quantity: order['quantity'],
              seller: order['seller'],
              date: order['date'],
              status: order['status'],
              statusColor: order['statusColor'],
              imageUrl: order['image'],
            ),
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
                child: Image.network(
                  order['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
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
                      '${order['productName']} ${order['quantity']}',
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
                          'Satıcı: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          order['seller'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Tarih: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          order['date'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
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
                        color: order['statusColor'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: order['statusColor'],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            order['status'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: order['statusColor'],
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
