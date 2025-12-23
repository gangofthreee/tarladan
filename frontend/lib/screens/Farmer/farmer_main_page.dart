import 'package:flutter/material.dart';
import 'farmer_create_ad.dart';
import 'farmer_all_ads.dart';
import 'farmer_ad_detail.dart';
import 'farmer_orders.dart';
import 'farmer_settings_page.dart';
import '../../services/user_service.dart';
import '../../services/farmer_product_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/notification_button.dart';
import '../../widgets/farmer_widgets.dart';
import '../../utils/page_transitions.dart';

class FarmerMainPage extends StatefulWidget {
  const FarmerMainPage({super.key});
  @override
  State<FarmerMainPage> createState() => _FarmerMainPageState();
}

class _FarmerMainPageState extends State<FarmerMainPage> {
  String _userName = 'Çiftçi';
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadProducts();
  }

  void _loadUserName() async {
    final name = await UserService.getUserFirstName();
    if (mounted) setState(() => _userName = name);
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await FarmerProductService.getAllProducts();
    if (mounted) {
      if (products != null) {
        setState(() {
          _products = products.reversed.toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  void _go(Widget page, {bool refresh = false}) async {
    await AppNavigator.push(context, page, transition: TransitionType.slideRight);
    if (refresh && mounted) _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return ThemedScaffold(
      useGradientBackground: true,
      appBar: ThemedAppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text('Tarladan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          actions: [NotificationButton()]),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        color: FarmerConstants.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Merhaba, $_userName', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 16),
            GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.55,
                children: [
                  FarmerActionCard(title: 'Açık İlanlarım', icon: Icons.format_list_bulleted, onTap: () => _go(const FarmerAllAds(), refresh: true)),
                  FarmerActionCard(title: 'Yeni İlan Aç', icon: Icons.add_circle_outline, onTap: () => _go(const FarmerCreateAd(), refresh: true)),
                  FarmerActionCard(title: 'Siparişlerim', icon: Icons.inventory_2_outlined, onTap: () => _go(const FarmerOrdersScreen())),
                  FarmerActionCard(title: 'Ayarlar', icon: Icons.settings, onTap: () => _go(const FarmerSettingsPage())),
                ]),
            const SizedBox(height: 12),
            Text('Son İlanlar', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 16),
            _isLoading ? const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator(color: FarmerConstants.primaryColor)))
                : _products.isEmpty ? const FarmerEmptyState(icon: Icons.inventory_2_outlined, message: 'Henüz ürün eklenmemiş')
                : Column(children: _products.map((p) => Padding(padding: const EdgeInsets.only(bottom: 12), child: FarmerProductItemCard(name: p['name'] ?? 'Ürün', ownerName: p['farmer_name'], amount: '${p['quantity_kg'] ?? 0} kg', price: '₺${p['price_per_kg'] ?? 0}/kg', status: 'Aktif', isActive: true, onTap: () => _go(FarmerAdDetail(productId: p['id'], canEdit: false))))).toList()),
          ]),
        ),
      ),
      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 0),
    );
  }
}
