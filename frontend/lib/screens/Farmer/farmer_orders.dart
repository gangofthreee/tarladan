import 'package:flutter/material.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/farmer_widgets.dart';
import '../../config/api_config.dart';
import '../../services/farmer_order_service.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});
  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  bool _showActive = true;
  List<dynamic> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    
    final (orders, error) = await FarmerOrderService.getOrders();
    
    if (mounted) {
      setState(() {
        if (orders != null) {
          _orders = orders;
        } else {
          _error = error;
        }
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => ThemedScaffold(
    appBar: ThemedAppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), title: const Text('Siparişlerim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
    body: Column(children: [
      const SizedBox(height: 16),
      Expanded(child: _loading ? const Center(child: CircularProgressIndicator(color: FarmerConstants.primaryColor))
          : _error != null ? FarmerErrorState(message: _error!, onRetry: _fetch)
          : _orders.isEmpty ? const FarmerEmptyState(icon: Icons.inventory_2_outlined, message: 'Henüz sipariş yok')
          : RefreshIndicator(onRefresh: _fetch, color: FarmerConstants.primaryColor, child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _orders.length, itemBuilder: (_, i) {
              final o = _orders[i];
              return Padding(padding: const EdgeInsets.only(bottom: 12), child: FarmerOrderCard(productName: o['productName'] ?? 'Ürün', buyer: o['customerName'] ?? 'Müşteri', depotName: o['locFrom'], quantityKg: o['quantityKg'], status: o['status'] ?? 'PENDING', date: o['orderDate'] ?? '', imagePath: o['product_image_path'], baseUrl: ApiConfig.baseUrl));
            }))),
      FarmerTabSelector(isFirstTabSelected: _showActive, firstTabLabel: 'Aktif Siparişler', secondTabLabel: 'Geçmiş Siparişler', onTabChanged: (v) => setState(() => _showActive = v)),
    ]),
    bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 2),
  );
}
