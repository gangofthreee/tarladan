import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../services/farmer_product_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/farmer_widgets.dart';
import 'farmer_ad_detail.dart';

class FarmerAllAds extends StatefulWidget {
  const FarmerAllAds({super.key});
  @override
  State<FarmerAllAds> createState() => _FarmerAllAdsState();
}

class _FarmerAllAdsState extends State<FarmerAllAds> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() { super.initState(); _fetchProducts(); }

  Future<void> _fetchProducts() async {
    setState(() { _isLoading = true; _errorMessage = null; });

    final products = await FarmerProductService.getMyProducts();
    if (!mounted) return;

    if (products != null) {
      setState(() {
        _products = products.reversed.toList();
        _isLoading = false;
      });
    } else {
      setState(() { _errorMessage = 'Ürünler yüklenemedi'; _isLoading = false; });
    }
  }

  void _navigateToDetail(int productId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FarmerAdDetail(productId: productId)),
    );
    if (result == true) _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      useGradientBackground: true,
      appBar: ThemedAppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('İlanlarım', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          FarmerTabSelector(
            isFirstTabSelected: true,
            firstTabLabel: 'Aktif',
            secondTabLabel: 'Geçmiş',
            onTabChanged: (_) {},
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildContent()),
        ],
      ),
      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: FarmerConstants.primaryColor));
    if (_errorMessage != null) return FarmerErrorState(message: _errorMessage!, onRetry: _fetchProducts);
    if (_products.isEmpty) return const FarmerEmptyState(icon: Icons.inventory_2_outlined, message: 'Henüz ilan eklemediniz');

    return RefreshIndicator(
      onRefresh: _fetchProducts,
      color: FarmerConstants.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final p = _products[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FarmerProductDetailCard(
              name: p['name'] ?? 'Ürün',
              quantityKg: (p['quantity_kg'] ?? 0).toDouble(),
              pricePerKg: (p['price_per_kg'] ?? 0).toDouble(),
              minBuy: (p['min_buy'] ?? 0).toDouble(),
              imagePath: p['image_path'],
              baseUrl: ApiConfig.baseUrl,
              onTap: () => _navigateToDetail(p['id'] ?? 0),
            ),
          );
        },
      ),
    );
  }
}
