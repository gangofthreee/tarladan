import 'package:flutter/material.dart';

import '../../widgets/themed_scaffold.dart';

class TruckerTruckUpdatePage extends StatefulWidget {
  final Map<String, dynamic> ad;

  const TruckerTruckUpdatePage({super.key, required this.ad});

  @override
  State<TruckerTruckUpdatePage> createState() => _TruckerTruckUpdatePageState();
}

class _TruckerTruckUpdatePageState extends State<TruckerTruckUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _truckSelectionController;
  late TextEditingController _availabilityController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _truckSelectionController = TextEditingController();
    _availabilityController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  void dispose() {
    _truckSelectionController.dispose();
    _availabilityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _showTruckSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final trucks = [
          'Ford F-150',
          'Chevrolet Silverado',
          'Dodge Ram 1500',
          'Toyota Tundra',
          'Mercedes-Benz Actros',
          'Volvo FH',
          'Scania R-Serisi',
        ];

        return AlertDialog(
          title: const Text('Tır Seç'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: trucks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(trucks[index]),
                  onTap: () {
                    setState(() {
                      _truckSelectionController.text = trucks[index];
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _handleUpdate() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('İlan güncellendi')));
      Navigator.pop(context);
    }
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlanı Sil'),
        content: const Text('Bu ilanı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('İlan silindi')));
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
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'İlan Düzenle',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tır Seç
                Text(
                  'Tır Seç',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _truckSelectionController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Tır seçin',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF4CAF50),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onTap: _showTruckSelectionDialog,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir tır seçin';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Müsaitlik durumu
                Text(
                  'Müsaitlik durumu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _availabilityController,
                  decoration: InputDecoration(
                    hintText: 'Örn: July 20, 2024, 10:00 AM',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF4CAF50),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen müsaitlik durumunu girin';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Taban fiyat
                Text(
                  'Taban fiyat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Fiyat girin',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF4CAF50),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen taban fiyatı girin';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // İptal ve Güncelle Butonları
                Row(
                  children: [
                    // İptal Butonu
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handleCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color,
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'İptal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Güncelle Butonu
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Güncelle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // İlanı Sil Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'İlanı Sil',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
