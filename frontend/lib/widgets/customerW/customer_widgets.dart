import 'package:flutter/material.dart';
import '../custom_bottom_navbar.dart';
import '../../screens/Customer/customer_viewOrders.dart';
import '../../screens/Customer/customer_settings_page.dart';
import '../../screens/Customer/customer_viewProductDetails_page.dart';
import '../../config/api_config.dart';
import '../notification_button.dart';

/// Customer için ortak kullanılan sabitler
class CustomerConstants {
  CustomerConstants._();

  /// Customer teması için ana renk
  static const Color primaryColor = Color(0xFF4CAF50);

  /// Bottom navigation bar item'ları
  static const List<BottomNavigationBarItem> bottomNavItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
    BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Siparişler'),
    BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Cüzdan'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
  ];
}

/// Customer sayfaları için ortak bottom navigation bar
class CustomerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final VoidCallback? onHomePressed;

  const CustomerBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onHomePressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      currentIndex: currentIndex,
      onTap: (index) => _handleNavTap(context, index),
      items: CustomerConstants.bottomNavItems,
    );
  }

  void _handleNavTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    if (index == 0) {
      Navigator.popUntil(context, (r) => r.isFirst);
      if (onHomePressed != null) onHomePressed!();
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerViewOrdersPage()));
    } else if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geliştirme Aşamasında'), duration: Duration(seconds: 1)));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerSettingsPage()));
    }
  }
}

/// Customer sayfası başlığı (Merhaba [Ad] ve Bildirim)
class CustomerHeader extends StatelessWidget {
  final String userName;

  const CustomerHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.transparent, // Arkaplan rengini kaldır
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tarladan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
              Text('Merhaba, $userName', style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color)),
            ],
          ),
          const NotificationButton(),
        ],
      ),
    );
  }
}

/// Arama çubuğu widget'ı
class CustomerSearchBar extends StatelessWidget {
  const CustomerSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: TextField(
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: 'Ürün ara...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}

/// Ürün verisi işleme yardımcısı
class CustomerProductHelper {
  static List<Map<String, dynamic>> processProducts(List<dynamic> dataList) {
    final products = dataList.map((data) {
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
        'image': imagePath != null ? '${ApiConfig.baseUrl}$imagePath' : 'https://images.unsplash.com/photo-1546470427-227e4c84d1da?w=400',
        'stock': data['quantity_kg'] ?? 0,
        'minBuy': data['min_buy'] ?? 0,
        'depot_id': data['depot_id'] ?? 1,
        'depot_latitude': data['depot_latitude'],
        'depot_longitude': data['depot_longitude'],
      };
    }).toList();
    products.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
    return products;
  }
}

/// Customer ürün kartı widget'ı
class CustomerProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const CustomerProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
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
              price: (product['price'] ?? 0).toDouble(),
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
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
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
                      color: CustomerConstants.primaryColor,
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
