import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../services/truck_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/trucker_widgets.dart';
import 'trucker_truckAdUpdate_page.dart';

class TruckerListAdsPage extends StatefulWidget {
  const TruckerListAdsPage({super.key});
  @override
  State<TruckerListAdsPage> createState() => _TruckerListAdsPageState();
}

class _TruckerListAdsPageState extends State<TruckerListAdsPage> {
  List<Map<String, dynamic>> ads = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() { super.initState(); _fetchAds(); }

  void _showMessage(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: isError ? Colors.red : kPrimaryColor));
  }

  Future<void> _fetchAds() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final loadedAds = await TruckService.getTruckAdsByTrucker();
      ads = loadedAds.map((data) {
        final imageUrl = data['imageUrl'];
        return {
          'id': data['adId'],
          'truckId': data['truckId'],
          'truckModel': data['vehicle'] ?? 'Araç Modeli',
          'plate': data['plate'] ?? '',
          'capacity': data['capacityTon'],
          'startDate': data['startDate'] ?? '',
          'endDate': data['endDate'] ?? '',
          'pricePerKm': data['pricePerKm'],
          'imageUrl': imageUrl != null && imageUrl.isNotEmpty ? '${ApiConfig.baseUrl}$imageUrl' : null,
          'truck': {'id': data['truckId'], 'model': data['vehicle'] ?? 'Araç Modeli', 'plate': data['plate'] ?? ''},
        };
      }).toList();
      ads.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleDelete(int adId) async {
    try {
      await TruckService.deleteTruckAd(adId);
      setState(() => ads.removeWhere((ad) => ad['id'] == adId));
      _showMessage('İlan silindi');
    } catch (e) {
      _showMessage('Hata: $e', isError: true);
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> ad) async {
    if (await showTruckerDeleteDialog(context, title: 'İlanı Sil', itemName: ad['truckModel'])) _handleDelete(ad['id']);
  }

  Future<void> _navigateAndRefresh(Widget page) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (result == true) _fetchAds();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      useGradientBackground: true,
      appBar: ThemedAppBar(title: const Text('İlanlarım'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), elevation: 0, backgroundColor: Colors.transparent),
      body: _isLoading
          ? const TruckerLoadingWidget(message: 'İlanlar yükleniyor...')
          : _errorMessage != null
              ? TruckerErrorWidget(errorMessage: _errorMessage!, onRetry: _fetchAds)
              : ads.isEmpty
                  ? const TruckerEmptyWidget(title: 'Henüz İlan Yok', message: 'Araçlarınız için ilan oluşturabilirsiniz', icon: Icons.campaign_outlined)
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: ads.length,
                      itemBuilder: (_, i) => TruckerAdCard(
                        ad: ads[i],
                        onEdit: () => _navigateAndRefresh(TruckerTruckUpdatePage(ad: ads[i])),
                        onDelete: () => _confirmDelete(ads[i]),
                      ),
                    ),
    );
  }
}
