import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../services/token_service.dart';
import 'trucker_truckAdUpdate_page.dart';

import '../../widgets/themed_scaffold.dart';

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
      final authHeaders = await TokenService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.getTruckerAdsUrl),
        headers: authHeaders,
      );

      print('🔄 Fetching my ads...');
      print('My Ads Response status: ${response.statusCode}');
      print('My Ads Response body: ${response.body}');

      // Yeni token varsa güncelle
      await TokenService.checkAndUpdateToken(response);

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);
        setState(() {
          ads = dataList.map((data) {
            return {
              'id': data['adId'],
              'truckModel': data['vehicle'] ?? 'Araç Modeli',
              'plate': data['plate'] ?? '',
              'startDate': data['startDate'] ?? '',
              'endDate': data['endDate'] ?? '',
              'pricePerKm': data['pricePerKm'],
            };
          }).toList();
          _isLoading = false;
        });
        print('✅ ${ads.length} ilan yüklendi');
      } else {
        setState(() {
          _errorMessage = 'İlanlar yüklenemedi: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ İlan yükleme hatası: $e');
      setState(() {
        _errorMessage = 'Bağlantı hatası: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: ThemedAppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'İlanlarım',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(fontSize: 16, color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchMyAds,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            )
          : ads.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz ilan yok',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: ads.length,
              itemBuilder: (context, index) {
                final ad = ads[index];
                return _buildAdCard(ad);
              },
            ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // Siparişler sekmesi seçili
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'İş Teklifleri',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Siparişler',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Cüzdan'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildAdCard(Map<String, dynamic> ad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // İlan Bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad['truckModel'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ad['plate']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),
                Text(
                  '${ad['startDate']} - ${ad['endDate']}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Düzenle Butonu
          InkWell(
            onTap: () {
              _showEditOptions(ad);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Düzenle',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditOptions(Map<String, dynamic> ad) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF4CAF50)),
                title: const Text('İlan Bilgilerini Düzenle'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TruckerTruckUpdatePage(ad: ad),
                    ),
                  );
                  // Güncelleme yapıldıysa listeyi yenile
                  if (result == true) {
                    _fetchMyAds();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text(
                  'İlanı Sil',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(ad);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(Map<String, dynamic> ad) {
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
              setState(() {
                ads.remove(ad);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('İlan başarıyla silindi')),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
