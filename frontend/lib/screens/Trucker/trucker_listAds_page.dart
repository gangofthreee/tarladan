import 'package:flutter/material.dart';
import 'trucker_truckAdUpdate_page.dart';

import '../../widgets/themed_scaffold.dart';
class TruckerListAdsPage extends StatefulWidget {
  const TruckerListAdsPage({super.key});

  @override
  State<TruckerListAdsPage> createState() => _TruckerListAdsPageState();
}

class _TruckerListAdsPageState extends State<TruckerListAdsPage> {
  // Örnek ilan verileri
  final List<Map<String, dynamic>> ads = [
    {'truckModel': 'Ford F-150', 'availableFrom': 'July 20, 2024, 10:00 AM'},
    {
      'truckModel': 'Chevrolet Silverado',
      'availableFrom': 'July 21, 2024, 2:00 PM',
    },
    {'truckModel': 'Dodge Ram 1500', 'availableFrom': 'July 22, 2024, 9:00 AM'},
    {'truckModel': 'Toyota Tundra', 'availableFrom': 'July 23, 2024, 4:00 PM'},
  ];

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
          style: TextStyle(
            
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ads.isEmpty
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
                const SizedBox(height: 6),
                Text(
                  'Available from ${ad['availableFrom']}',
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
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TruckerTruckUpdatePage(ad: ad),
                    ),
                  );
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
                const SnackBar(
                  content: Text('İlan başarıyla silindi'),                ),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
