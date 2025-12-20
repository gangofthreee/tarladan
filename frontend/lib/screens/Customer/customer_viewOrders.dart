import 'package:flutter/material.dart';
import '../../services/customer_order_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/customerW/customer_order_widgets.dart';
import 'customer_viewOrderDetail_page.dart';

class CustomerViewOrdersPage extends StatefulWidget {
  const CustomerViewOrdersPage({super.key});

  @override
  State<CustomerViewOrdersPage> createState() => _CustomerViewOrdersPageState();
}

class _CustomerViewOrdersPageState extends State<CustomerViewOrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ordersFuture = CustomerOrderService.getOrders();
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
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Siparişlerim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }

                final orders = snapshot.data ?? [];
                // PENDING -> Active, Others -> Past
                final activeOrders = orders.where((o) => o['status'] == 'PENDING').toList();
                final pastOrders = orders.where((o) => o['status'] != 'PENDING').toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrderList(activeOrders),
                    _buildOrderList(pastOrders),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() => Container(
    color: Theme.of(context).cardColor,
    child: TabBar(
      controller: _tabController,
      indicatorColor: const Color(0xFF4CAF50),
      labelColor: const Color(0xFF4CAF50),
      unselectedLabelColor: Colors.grey[600],
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      tabs: const [
        Tab(text: 'Aktif Siparişler'),
        Tab(text: 'Geçmiş Siparişler'),
      ],
    ),
  );

  Widget _buildOrderList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Henüz sipariş yok', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) => OrderCard(
        order: orders[index],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CustomerViewOrderDetailPage(orderId: orders[index]['id'] ?? 0)),
        ),
      ),
    );
  }
}
