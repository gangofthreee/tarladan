import 'package:flutter/material.dart';
import '../../services/truck_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/customerW/customer_select_truck_widgets.dart';

class CustomerSelectTruckPage extends StatefulWidget {
  const CustomerSelectTruckPage({super.key});
  @override
  State<CustomerSelectTruckPage> createState() => _CustomerSelectTruckPageState();
}

class _CustomerSelectTruckPageState extends State<CustomerSelectTruckPage> {
  String? _selectedTruckId;
  late Future<List<Map<String, dynamic>>> _trucksFuture;

  @override
  void initState() {
    super.initState();
    _trucksFuture = _fetchTrucks();
  }

  Future<List<Map<String, dynamic>>> _fetchTrucks() {
    return TruckService.getAvailableTruckAds(
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 365)),
    ).then((ads) => ads.map((ad) => {
          'id': ad['adId'].toString(),
          'truckId': ad['truckId'],
          'truckerName': ad['truckerName'] ?? 'Bilinmiyor',
          'vehicle': ad['vehicle'] ?? 'Araç Bilgisi Yok',
          'capacity': ad['capacityTon'] ?? 0,
          'basePrice': ad['pricePerKm'] ?? 0.0,
          'priceUnit': '₺/km',
          'plate': ad['plate'] ?? '',
          'availability': '${ad['startDate']} - ${ad['endDate']}',
          'imageUrl': ad['imageUrl'],
          'icon': '🚛',
        }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      useCustomerBackground: true,
      appBar: ThemedAppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Tır Seç', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _trucksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
          if (snapshot.hasError) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              Padding(padding: const EdgeInsets.all(16), child: Text('Hata: ${snapshot.error}', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)),
              ElevatedButton(onPressed: () => setState(() => _trucksFuture = _fetchTrucks()), child: const Text('Tekrar Dene')),
            ]));
          }
          final trucks = snapshot.data ?? [];
          if (trucks.isEmpty) return const Center(child: Text('Uygun tır ilanı bulunamadı', style: TextStyle(color: Colors.grey)));

          final selectedTruck = _selectedTruckId != null ? trucks.firstWhere((t) => t['id'] == _selectedTruckId, orElse: () => {}) : null;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: trucks.length,
                  itemBuilder: (context, index) => TruckAdCard(
                    truck: trucks[index],
                    isSelected: trucks[index]['id'] == _selectedTruckId,
                    onTap: () => setState(() => _selectedTruckId = trucks[index]['id']),
                  ),
                ),
              ),
              if (selectedTruck != null && selectedTruck.isNotEmpty)
                SelectedTruckBottomBar(truck: selectedTruck, onConfirm: () => Navigator.pop(context, selectedTruck)),
            ],
          );
        },
      ),
    );
  }
}

