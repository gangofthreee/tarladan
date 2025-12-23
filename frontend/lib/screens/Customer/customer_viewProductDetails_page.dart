import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/themed_scaffold.dart';
import '../../utils/page_transitions.dart';
import 'customer_purchaseProduct_page.dart';

class CustomerViewProductDetailsPage extends StatelessWidget {
  final int productId, depotId, availableQuantity, reviewCount, minBuy;
  final String productName, farmerName, unit, imageUrl;
  final double price, rating;
  final double? depotLatitude, depotLongitude;

  const CustomerViewProductDetailsPage({
    super.key, required this.productId, required this.depotId, required this.productName,
    required this.farmerName, required this.price, required this.unit, required this.imageUrl,
    this.availableQuantity = 500, this.minBuy = 1, this.rating = 4.8, this.reviewCount = 120,
    this.depotLatitude, this.depotLongitude,
  });

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      useGradientBackground: true,
      appBar: ThemedAppBar(
        elevation: 0, centerTitle: true, backgroundColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Ürün Detayları', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 300,
              color: Colors.transparent,
              child: Image.network(imageUrl, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Icon(Icons.image_not_supported, size: 100, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(productName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('₺${price.toStringAsFixed(2)} $unit', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Text('Mevcut Miktar: ', style: TextStyle(fontSize: 16, color: Colors.black87)),
                    Text('$availableQuantity kg', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ]),
                ),
                const SizedBox(height: 30),
                const Text('Satıcı Bilgileri', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).cardColor
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05), blurRadius: 5)
                      ]),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(farmerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(children: [
                        const Icon(Icons.star, color: Color(0xFF4CAF50), size: 18),
                        const SizedBox(width: 4),
                        Text('$rating ($reviewCount değerlendirme)', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      ]),
                    ])),
                    const Icon(Icons.chevron_right),
                  ]),
                ),
                const SizedBox(height: 30),
                const Text('Depo Konumu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (depotLatitude != null && depotLongitude != null)
                        ? FlutterMap(
                            options: MapOptions(initialCenter: LatLng(depotLatitude!, depotLongitude!), initialZoom: 13.0),
                            children: [
                              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.gangofthree.tarladan'),
                              MarkerLayer(markers: [Marker(point: LatLng(depotLatitude!, depotLongitude!), width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.red, size: 40))]),
                            ],
                          )
                        : Container(color: Colors.grey[200], child: const Center(child: Text('Konum bilgisi mevcut değil'))),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => AppNavigator.push(context, CustomerPurchaseProductPage(
                      productId: productId, depotId: depotId, productName: productName, imageUrl: imageUrl,
                      price: price, unit: unit, availableQuantity: availableQuantity, minBuy: minBuy,
                      depotLatitude: depotLatitude, depotLongitude: depotLongitude,
                    ), transition: TransitionType.slideUp),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Hemen Al', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
