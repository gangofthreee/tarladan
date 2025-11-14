import 'package:flutter/material.dart';

import '../../widgets/themed_scaffold.dart';
class CustomerSelectTruckPage extends StatefulWidget {
  const CustomerSelectTruckPage({super.key});

  @override
  State<CustomerSelectTruckPage> createState() =>
      _CustomerSelectTruckPageState();
}

class _CustomerSelectTruckPageState extends State<CustomerSelectTruckPage> {
  String? _selectedTruckId;

  // Örnek tır verileri
  final List<Map<String, dynamic>> trucks = [
    {
      'id': 'truck1',
      'driverName': 'Ahmet Yılmaz',
      'brand': 'Volvo',
      'capacity': 20,
      'rating': 4.8,
      'priceUnit': '₺/km',
      'icon': '🚛',
    },
    {
      'id': 'truck2',
      'driverName': 'Mehmet Demir',
      'brand': 'Mercedes',
      'capacity': 18,
      'rating': 4.5,
      'priceUnit': '₺/sefer',
      'icon': '🚚',
    },
    {
      'id': 'truck3',
      'driverName': 'Ayşe Kaya',
      'brand': 'Scania',
      'capacity': 22,
      'rating': 4.9,
      'priceUnit': '₺/km',
      'icon': '🚛',
    },
  ];

  void _handleConfirm() {
    if (_selectedTruckId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir tır seçiniz'),        ),
      );
      return;
    }

    // Return selected truck to previous page
    Navigator.pop(context, _selectedTruckId);
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
          style: TextStyle(
            
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Truck List
          Expanded(
            child: ListView.builder(
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
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
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
                      child: Text(
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
                          selectedTruck['driverName'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${selectedTruck['brand']}, ${selectedTruck['capacity']} ton',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
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
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
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
                    truck['driverName'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${truck['brand']}, ${truck['capacity']} ton',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFC107),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${truck['rating']} (${truck['priceUnit']})',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Select Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
