import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import '../../config/api_config.dart';
import '../../services/token_service.dart';
import '../../widgets/location_picker_widget.dart';

import '../../widgets/themed_scaffold.dart';

class WarehousemanCreateWarehousePage extends StatefulWidget {
  final int depoOwnerId; // Warehouseman ID'si

  const WarehousemanCreateWarehousePage({super.key, required this.depoOwnerId});

  @override
  State<WarehousemanCreateWarehousePage> createState() =>
      _WarehousemanCreateWarehousePageState();
}

class _WarehousemanCreateWarehousePageState
    extends State<WarehousemanCreateWarehousePage> {
  final _formKey = GlobalKey<FormState>();
  final _sizeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;
  LatLng? _selectedLocation;

  @override
  void dispose() {
    _sizeController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen haritadan bir konum seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authHeaders = await TokenService.getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.createDepotUrl),
        headers: authHeaders,
        body: json.encode({
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
          'sizeM2': double.parse(_sizeController.text),
          'capacityTon': double.parse(_capacityController.text),
          'price': double.parse(_priceController.text),
        }),
      );

      await TokenService.checkAndUpdateToken(response);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Depo başarıyla eklendi!'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true); // true ile geri dön, liste güncellensin
      } else {
        final errorMessage = response.body.isNotEmpty
            ? json.decode(response.body)['error'] ?? 'Bilinmeyen hata'
            : 'Hata: ${response.statusCode}';

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Bağlantı hatası: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
          'Depo Ekle',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Konum Seç Butonu
                Text(
                  'Konum',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationPickerWidget(
                          initialLocation: _selectedLocation,
                          onLocationSelected: (location, address) {
                            setState(() {
                              _selectedLocation = location;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[850]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedLocation != null
                            ? const Color(0xFF4CAF50)
                            : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!),
                        width: _selectedLocation != null ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedLocation != null
                              ? Icons.location_on
                              : Icons.location_off,
                          color: _selectedLocation != null
                              ? const Color(0xFF4CAF50)
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedLocation != null
                                ? 'Konum seçildi: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}'
                                : 'Haritadan konum seçin',
                            style: TextStyle(
                              color: _selectedLocation != null
                                  ? (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black87)
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[600]
                              : Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Boyut Field
                Text(
                  'Boyut (m²)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _sizeController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Boyut giriniz',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]!
                            : Colors.grey[300]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]!
                            : Colors.grey[300]!,
                      ),
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
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen boyut giriniz';
                    }
                    final number = double.tryParse(value);
                    if (number == null) {
                      return 'Lütfen geçerli bir sayı giriniz';
                    }
                    if (number <= 0) {
                      return 'Boyut 0 veya negatif olamaz';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Kapasite Field
                Text(
                  'Kapasite (ton)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Kapasite giriniz',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]!
                            : Colors.grey[300]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]!
                            : Colors.grey[300]!,
                      ),
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
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen kapasite giriniz';
                    }
                    final number = double.tryParse(value);
                    if (number == null) {
                      return 'Lütfen geçerli bir sayı giriniz';
                    }
                    if (number <= 0) {
                      return 'Kapasite 0 veya negatif olamaz';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Fiyat Field
                Text(
                  'Fiyat (₺)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Fiyat giriniz',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]!
                            : Colors.grey[300]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]!
                            : Colors.grey[300]!,
                      ),
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
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen fiyat giriniz';
                    }
                    final number = double.tryParse(value);
                    if (number == null) {
                      return 'Lütfen geçerli bir sayı giriniz';
                    }
                    if (number <= 0) {
                      return 'Fiyat 0 veya negatif olamaz';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // Butonlar
                Row(
                  children: [
                    // İptal Butonu
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: OutlinedButton(
                          onPressed: _handleCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.color,
                            side: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 1.5,
                            ),
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
                    ),

                    const SizedBox(width: 12),

                    // Ekle Butonu
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Ekle',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
