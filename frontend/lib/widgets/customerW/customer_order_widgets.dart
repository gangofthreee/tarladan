import 'package:flutter/material.dart';
import '../../config/api_config.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // API response formatını parse et
    final productName = order['productName'] ?? 'Ürün';
    final quantity = '${order['quantityKg'] ?? 0}kg';
    final locFrom = order['locFrom'] ?? '';
    final locTo = order['locTo'] ?? '';
    final totalPrice = order['totalPrice'] ?? 0;
    final status = order['status'] ?? 'PENDING';

    // Image path dönüştür (/app/uploads/ -> /uploads/)
    String? imagePath = order['product_image_path'];
    if (imagePath != null && imagePath.startsWith('/app/uploads/')) {
      imagePath = imagePath.replaceFirst('/app/uploads/', '/uploads/');
    }
    final imageUrl = imagePath != null
        ? '${ApiConfig.baseUrl}$imagePath'
        : 'https://images.unsplash.com/photo-1546470427-227e4c84d1da?w=400';

    // Status config
    final statusConfig = _getStatusConfig(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white.withOpacity(0.7),
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               // Product Image
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: Container(
                  width: 120,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        child: const Icon(Icons.shopping_bag_outlined, size: 50, color: Color(0xFF4CAF50)),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$productName $quantity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(context, 'Toplam: ', '${totalPrice}₺', true),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '$locFrom → $locTo',
                              style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusConfig.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusConfig.icon, size: 16, color: statusConfig.color),
                            const SizedBox(width: 6),
                            Text(
                              statusConfig.text,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: statusConfig.color),
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
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, bool isValueColored) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isValueColored ? const Color(0xFF4CAF50) : null)),
      ],
    );
  }

  ({Color color, String text, IconData icon}) _getStatusConfig(String status) {
    switch (status) {
      case 'PENDING':
        return (color: const Color(0xFFFFA726), text: 'Beklemede', icon: Icons.access_time);
      case 'COMPLETED':
        return (color: const Color(0xFF4CAF50), text: 'Tamamlandı', icon: Icons.check_circle);
      default:
        return (color: const Color(0xFF2196F3), text: status, icon: Icons.info);
    }
  }
}
