import 'package:flutter/material.dart';
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
  void initState() {
    super.initState();
    _fetchMyAds();
  }

  Future<void> _fetchMyAds() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final loadedAds = await TruckService.getTruckAdsByTrucker();
      ads = loadedAds.map((data) {
        return {
          'id': data['adId'],
          'truckId': data['truckId'],
          'truckModel': data['vehicle'] ?? 'Araç Modeli',
          'plate': data['plate'] ?? '',
          'startDate': data['startDate'] ?? '',
          'endDate': data['endDate'] ?? '',
          'pricePerKm': data['pricePerKm'],
          'truck': {
            'id': data['truckId'],
            'model': data['vehicle'] ?? 'Araç Modeli',
            'plate': data['plate'] ?? '',
          },
        };
      }).toList();
    } catch (e) {
      _errorMessage = 'Bağlantı hatası: $e';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _handleDelete(int adId) async {
    try {
      await TruckService.deleteTruckAd(adId);
      setState(() => ads.removeWhere((ad) => ad['id'] == adId));
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('İlan silindi')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> ad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlanı Sil'),
        content: Text(
          '${ad['truckModel']} ilanını silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDelete(ad['id']);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: ThemedAppBar(
        title: const Text('İlanlarım'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const TruckerLoadingWidget(message: 'İlanlar yükleniyor...')
          : _errorMessage != null
          ? TruckerErrorWidget(
              errorMessage: _errorMessage!,
              onRetry: _fetchMyAds,
            )
          : ads.isEmpty
          ? const TruckerEmptyWidget(
              title: 'Henüz İlan Yok',
              message: 'Araçlarınız için ilan oluşturabilirsiniz',
              icon: Icons.campaign_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: ads.length,
              itemBuilder: (context, index) {
                final ad = ads[index];
                return TruckerAdCard(
                  ad: ad,
                  onEdit: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TruckerTruckUpdatePage(ad: ad),
                      ),
                    );
                    if (result == true) _fetchMyAds();
                  },
                  onDelete: () => _showDeleteConfirmation(ad),
                );
              },
            ),
    );
  }
}
