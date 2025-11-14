import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import 'warehouseman_updateWarehouseInfo_page.dart';

import '../../widgets/themed_scaffold.dart';
class WarehousemanMyWarehouseDetailPage extends StatefulWidget {
  final int depotId;

  const WarehousemanMyWarehouseDetailPage({super.key, required this.depotId});

  @override
  State<WarehousemanMyWarehouseDetailPage> createState() =>
      _WarehousemanMyWarehouseDetailPageState();
}

class _WarehousemanMyWarehouseDetailPageState
    extends State<WarehousemanMyWarehouseDetailPage> {
  Map<String, dynamic>? _depotData;
  bool _isLoading = true;
  String? _errorMessage;
  bool _wasUpdated = false; // Güncelleme yapıldı mı?

  @override
  void initState() {
    super.initState();
    _fetchDepotDetails();
  }

  Future<void> _fetchDepotDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getDepotByIdUrl(widget.depotId)),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _depotData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Depo detayları yüklenemedi: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Bağlantı hatası: $e';
        _isLoading = false;
      });
    }
  }

  // Örnek rezervasyon verileri
  final List<Map<String, dynamic>> reservations = [
    {'farmerName': 'Çiftçi A', 'amount': 150, 'image': 'assets/farmer1.jpg'},
    {'farmerName': 'Çiftçi B', 'amount': 200, 'image': 'assets/farmer2.jpg'},
    {'farmerName': 'Çiftçi C', 'amount': 250, 'image': 'assets/farmer3.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
            appBar: ThemedAppBar(
                elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _wasUpdated),
        ),
        title: const Text(
          'Depo Detayları',
          style: TextStyle(
            
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _fetchDepotDetails,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            )
          : _depotData == null
          ? const Center(child: Text('Depo bulunamadı'))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Depo Bilgileri Section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Depo Bilgileri',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Adres
                        _buildInfoCard(
                          icon: Icons.location_on,
                          iconColor: const Color(0xFF4CAF50),
                          title: 'Adres',
                          subtitle:
                              _depotData!['address'] ?? 'Adres bilgisi yok',
                        ),

                        const SizedBox(height: 12),

                        // Kapasite
                        _buildInfoCard(
                          icon: Icons.warehouse,
                          iconColor: const Color(0xFF4CAF50),
                          title: 'Kapasite',
                          subtitle:
                              '${(_depotData!['capacityTon'] ?? 0).toStringAsFixed(0)} ton',
                        ),

                        const SizedBox(height: 12),

                        // Fiyat
                        _buildInfoCard(
                          icon: Icons.attach_money,
                          iconColor: const Color(0xFF4CAF50),
                          title: 'Fiyat',
                          subtitle:
                              '${(_depotData!['price'] ?? 0).toStringAsFixed(2)} ₺',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Mevcut Doluluk Section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mevcut Doluluk',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kapasite: ${(_depotData!['capacityTon'] ?? 0).toStringAsFixed(0)} ton',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Alan: ${(_depotData!['sizeM2'] ?? 0).toStringAsFixed(0)} m²',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Fiyat: ${(_depotData!['price'] ?? 0).toStringAsFixed(2)} ₺',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Mevcut Rezervasyonlar Section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mevcut Rezervasyonlar',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Rezervasyon Listesi
                        ...reservations.map(
                          (reservation) => _buildReservationCard(reservation),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Alt Butonlar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Düzenle Butonu
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        WarehousemanUpdateWarehouseInfoPage(
                                          depotId: widget.depotId,
                                          warehouseName:
                                              'Depo #${widget.depotId}',
                                          currentAddress:
                                              _depotData!['address'] ?? '',
                                          currentSize:
                                              (_depotData!['sizeM2'] ?? 0)
                                                  .toString(),
                                          currentCapacity:
                                              (_depotData!['capacityTon'] ?? 0)
                                                  .toString(),
                                          currentPrice:
                                              (_depotData!['price'] ?? 0)
                                                  .toString(),
                                        ),
                                  ),
                                );
                                // Eğer güncelleme yapıldıysa sayfayı yenile
                                if (result == true) {
                                  setState(() {
                                    _wasUpdated = true;
                                  });
                                  _fetchDepotDetails();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Düzenle',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Depoyu Sil Butonu
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () {
                                _showDeleteDialog();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE57373),
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Depoyu Sil',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> reservation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 25,
                        child: const Icon(Icons.person, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation['farmerName'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${reservation['amount']} ton',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDepot() async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.deleteDepotUrl(widget.depotId)),
        headers: {'Content-Type': 'application/json'},
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Başarılı silme
        Navigator.pop(context, true); // Detay sayfasından çık ve listeyi yenile
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Depo başarıyla silindi'),
                      ),
        );
      } else {
        // Hata durumu
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Depo silinemedi: ${response.statusCode}'),          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bağlantı hatası: $e'),        ),
      );
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Depoyu Sil',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Bu depoyu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('İptal', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Dialog'u kapat
                _deleteDepot(); // Silme işlemini çalıştır
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE57373),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }
}
