import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../services/customer_order_service.dart';
import '../../widgets/themed_scaffold.dart';

class CustomerViewOrderDetailPage extends StatelessWidget {
  final int orderId;
  const CustomerViewOrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      useGradientBackground: true,
      appBar: ThemedAppBar(
        elevation: 0, centerTitle: true, backgroundColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Sipariş Detayı', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: CustomerOrderService.getOrderDetail(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
          if (snapshot.hasError) return Center(child: Text('Hata: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          final order = snapshot.data!;
          final imageUrl = order['product_image_path']?.startsWith('/app/') == true 
             ? '${ApiConfig.baseUrl}${order['product_image_path'].replaceFirst('/app/', '/')}'
             : 'https://images.unsplash.com/photo-1546470427-227e4c84d1da?w=400';
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Sipariş Özeti', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).cardColor
                      : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(children: [
                   ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.error))),
                   const SizedBox(width: 16),
                   Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                     Text(order['productName'] ?? 'Ürün', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                     Text('${order['quantityKg'] ?? 0}kg', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                     Text('${order['totalPrice'] ?? 0}₺', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                   ])),
                ]),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).cardColor
                      : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Sipariş Detayları', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _row(context, 'Fiyat/kg', '${order['pricePerKg'] ?? 0}₺'),
                  _row(context, 'Miktar', '${order['quantityKg'] ?? 0}kg'),
                  _row(context, 'Toplam', '${order['totalPrice'] ?? 0}₺', isBold: true, color: const Color(0xFF4CAF50)),
                  const Divider(height: 30),
                  _row(context, 'Nereden', _fmtLoc(order['locFrom'])),
                  _row(context, 'Nereye', _fmtLoc(order['locTo'])),
                  const Divider(height: 30),
                  _row(context, 'Plaka', order['truckPlate'] ?? '-'),
                  const Divider(height: 30),
                  _row(context, 'Durum', _status(order['status']).text, isBold: true, color: _status(order['status']).color),
                ]),
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _row(BuildContext context, String k, String v, {bool isBold = false, Color? color}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
      Flexible(child: Text(v, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color)))
    ]),
  );

  String _fmtLoc(String? s) => (s?.split(',').length ?? 0) >= 2 ? '${s!.split(',')[1].trim()} / ${s.split(',')[0].trim()}' : s ?? '';
  
  ({String text, Color color}) _status(String? s) => switch(s) {
    'PENDING' => (text: 'Beklemede', color: const Color(0xFFFFA726)),
    'COMPLETED' => (text: 'Tamamlandı', color: const Color(0xFF4CAF50)),
    'CANCELLED' => (text: 'İptal', color: Colors.red),
    _ => (text: s ?? '-', color: Colors.blue)
  };
}
