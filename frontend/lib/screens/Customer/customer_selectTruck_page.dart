import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../services/token_service.dart';
import '../../services/truck_service.dart';

import '../../widgets/themed_scaffold.dart';

class CustomerSelectTruckPage extends StatefulWidget {
  const CustomerSelectTruckPage({super.key});

  @override
  State<CustomerSelectTruckPage> createState() =>
      _CustomerSelectTruckPageState();
}

class _CustomerSelectTruckPageState extends State<CustomerSelectTruckPage> {
  String? _selectedTruckId;
  List<Map<String, dynamic>> trucks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAvailableTruckAds();
  }

  Future<void> _fetchAvailableTruckAds() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Search for ads in the next 1 year (fetching effectively all active ads)
      final startDate = DateTime.now();
      final endDate = startDate.add(const Duration(days: 365));

      final ads = await TruckService.getAvailableTruckAds(
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        trucks = ads.map((ad) {
          return {
            'id': ad['adId'].toString(), // Use adId as unique identifier in list
            'truckId': ad['truckId'],
            'driverName': ad['truckerName'] ?? 'Bilinmiyor',
            'driverSurname': '',
            'brand': ad['vehicle'] ?? 'Araç Bilgisi Yok',
            'capacity': ad['capacityTon'] ?? 0,
            'basePrice': ad['pricePerKm'] ?? 0.0,
            'priceUnit': '₺/km',
            'plate': ad['plate'] ?? '',
            'availability': '${ad['startDate']} - ${ad['endDate']}',
            'imageUrl': ad['imageUrl'],
            'icon': '🚛',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Hata: $e';
        _isLoading = false;
      });
    }
  }

  void _handleConfirm() {
    if (_selectedTruckId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir tır seçiniz')));
      return;
    }

    // Find selected truck and return its info
    final selectedTruck = trucks.firstWhere(
      (truck) => truck['id'] == _selectedTruckId,
    );

    // Return truck data
    Navigator.pop(context, {
      'truckId': selectedTruck['truckId'],
      'truckerName': selectedTruck['driverName'],
      'vehicle': selectedTruck['brand'],
      'plate': selectedTruck['plate'],
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedTruck = _selectedTruckId != null
        ? trucks.firstWhere((truck) => truck['id'] == _selectedTruckId)
        : null;

    return ThemedScaffold(
      appBar: ThemedAppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tır Seç',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Truck List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                  )
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchAvailableTruckAds,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                          ),
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  )
                : trucks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Uygun tır ilanı bulunamadı',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: trucks.length,
                    itemBuilder: (context, index) {
                      final truck = trucks[index];
                      final isSelected = truck['id'] == _selectedTruckId;
                      return _buildTruckCard(truck, isSelected);
                    },
                  ),
          ),

          // Bottom Selected Truck and Confirm Button
          if (selectedTruck != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Selected Truck Info
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: selectedTruck['imageUrl'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                '${ApiConfig.baseUrl}${selectedTruck['imageUrl']}',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Text(
                                  selectedTruck['icon'],
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                            )
                          : Text(
                              selectedTruck['icon'],
                              style: const TextStyle(fontSize: 40),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sürücü: ${selectedTruck['driverName']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Araç: ${selectedTruck['brand']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Plaka: ${selectedTruck['plate']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Confirm Button
                  ElevatedButton(
                    onPressed: _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Onayla',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTruckCard(Map<String, dynamic> truck, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTruckId = truck['id'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Truck Icon/Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: truck['imageUrl'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          '${ApiConfig.baseUrl}${truck['imageUrl']}',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Text(
                            truck['icon'],
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      )
                    : Text(
                        truck['icon'],
                        style: const TextStyle(fontSize: 40),
                      ),
              ),
            ),

            const SizedBox(width: 16),

            // Truck Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sürücü: ${truck['driverName']} ${truck['driverSurname']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Araç: ${truck['brand']}',
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.9)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Plaka: ${truck['plate']}',
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.9)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kapasite: ${truck['capacity']} ton',
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fiyat: ${truck['basePrice']} ${truck['priceUnit']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Müsaitlik: ${truck['availability']}',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Select Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Seç',
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
