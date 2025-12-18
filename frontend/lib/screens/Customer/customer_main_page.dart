import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'customer_viewProductDetails_page.dart';
import 'customer_viewOrders.dart';
import 'customer_settings_page.dart';
import '../../services/user_service.dart';
import '../../services/token_service.dart';
import '../../config/api_config.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/notification_button.dart';

class CustomerMainPage extends StatefulWidget {
  const CustomerMainPage({super.key});

  @override
  State<CustomerMainPage> createState() => _CustomerMainPageState();
}

class _CustomerMainPageState extends State<CustomerMainPage> {
  int _selectedIndex = 0;
  String _userName = 'Müşteri';
  List<Map<String, dynamic>> products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadProducts();
  }

  Future<void> _loadUserName() async {
    final name = await UserService.getUserFirstName();
    setState(() {
      _userName = name;
    });
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final authHeaders = await TokenService.getAuthHeaders();
      print('🌐 API URL: ${ApiConfig.getAllProductsUrl}');
      final response = await http.get(
        Uri.parse(ApiConfig.getAllProductsUrl),
        headers: authHeaders,
      );

      print('📦 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      await TokenService.checkAndUpdateToken(response);

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);
        print('✅ Products loaded: ${dataList.length} items');
        setState(() {
          products = dataList.map((data) {
            print('🔍 Product data: $data');

            // Image path dönüştürülür (/app/uploads/ -> /uploads/)
            String? imagePath = data['image_path'];
            if (imagePath != null && imagePath.startsWith('/app/uploads/')) {
              imagePath = imagePath.replaceFirst('/app/uploads/', '/uploads/');
            }

            return {
              'id': data['id'],
              'name': data['name'] ?? 'Ürün',
              'farmer': data['farmer_name'] ?? 'Çiftçi',
              'price': data['price_per_kg'] ?? 0,
              'unit': '₺/kg',
              'image': imagePath != null
                  ? '${ApiConfig.baseUrl}$imagePath'
                  : 'https://images.unsplash.com/photo-1546470427-227e4c84d1da?w=400',
              'stock': data['quantity_kg'] ?? 0,
              'minBuy': data['min_buy'] ?? 0,
              'depot_id': data['depot_id'] ?? 1,
              'depot_latitude': data['depot_latitude'],
              'depot_longitude': data['depot_longitude'],
            };
          }).toList();
          // Sort products by ID descending (newest first)
          products.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
          print('✅ Total products after mapping and sorting: ${products.length}');
        });
      } else {
        print('❌ Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Ürün yükleme hatası: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      // Navigate to orders page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CustomerViewOrdersPage()),
      );
    } else if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geliştirme Aşamasında'),
          duration: Duration(seconds: 1),
        ),
      );
    } else if (index == 3) {
      // Navigate to settings page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CustomerSettingsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              color: Theme.of(context).cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tarladan',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        'Merhaba, $_userName',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const NotificationButton(),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E1E1E)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ürün ara...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Products Grid
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    )
                  : products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz ürün bulunamadı',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductCard(product);
                      },
                    ),
            ),
          ],
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
              icon: Icon(Icons.receipt_long),
              label: 'Siparişler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Cüzdan',
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

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerViewProductDetailsPage(
              productId: product['id'],
              depotId: product['depot_id'] ?? 1,
              productName: product['name'],
              farmerName: product['farmer'],
              price: product['price'].toDouble(),
              unit: product['unit'],
              imageUrl: product['image'],
              availableQuantity: product['stock'] ?? 0,
              depotLatitude: product['depot_latitude'],
              depotLongitude: product['depot_longitude'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                color: Colors.grey[200],
                child: Image.network(
                  product['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product['farmer'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${product['price']} ${product['unit']}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
