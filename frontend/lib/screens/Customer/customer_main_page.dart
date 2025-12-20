import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../services/farmer_product_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/customerW/customer_widgets.dart';

class CustomerMainPage extends StatefulWidget {
  const CustomerMainPage({super.key});

  @override
  State<CustomerMainPage> createState() => _CustomerMainPageState();
}

class _CustomerMainPageState extends State<CustomerMainPage> {
  String _userName = 'Müşteri';
  List<Map<String, dynamic>> products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final name = await UserService.getUserFirstName();
    if (mounted) setState(() => _userName = name);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final list = await FarmerProductService.getAllProducts();
    if (mounted) {
      if (list != null) {
        setState(() {
          products = CustomerProductHelper.processProducts(list);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomerHeader(userName: _userName),
            const CustomerSearchBar(),
            const SizedBox(height: 10),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      bottomNavigationBar: const CustomerBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: CustomerConstants.primaryColor));
    }
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Henüz ürün bulunamadı', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => CustomerProductCard(product: products[index]),
    );
  }
}
