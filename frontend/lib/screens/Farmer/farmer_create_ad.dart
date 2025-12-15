import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../config/api_config.dart';
import '../../services/token_service.dart';
import '../../services/geocoding_service.dart';

import '../../widgets/themed_scaffold.dart';

class FarmerCreateAd extends StatefulWidget {
  const FarmerCreateAd({super.key});

  @override
  _FarmerCreateAdState createState() => _FarmerCreateAdState();
}

class _FarmerCreateAdState extends State<FarmerCreateAd> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController productController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController minBuyController = TextEditingController();

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  List<dynamic> _depots = [];
  int? _selectedDepotId;
  bool _isLoadingDepots = false;
  Map<int, String> _depotAddresses = {}; // Cache for geocoded addresses

  @override
  void initState() {
    super.initState();
    _fetchDepots();
  }

  Future<void> _fetchDepots() async {
    setState(() {
      _isLoadingDepots = true;
    });

    try {
      final authHeaders = await TokenService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.getAllDepotsUrl),
        headers: authHeaders,
      );

      await TokenService.checkAndUpdateToken(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _depots = data is List ? data : [data];
          _isLoadingDepots = false;
        });
        // Load addresses for each depot
        _loadDepotAddresses();
      } else {
        setState(() {
          _isLoadingDepots = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingDepots = false;
      });
    }
  }

  Future<void> _loadDepotAddresses() async {
    final futures = _depots.map((depot) async {
      final depotId = depot['id'] as int;
      final latitude = depot['latitude'] as double?;
      final longitude = depot['longitude'] as double?;

      if (latitude != null && longitude != null) {
        try {
          final cityAndDistrict = await GeocodingService.getCityAndDistrict(
            latitude,
            longitude,
          );

          if (mounted) {
            setState(() {
              _depotAddresses[depotId] = cityAndDistrict;
            });
          }
        } catch (e) {
          print('Adres yüklenemedi (Depo $depotId): $e');
        }
      }
    }).toList();

    await Future.wait(futures);
  }

  void _showDepotSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Depo Seç'),
          content: _isLoadingDepots
              ? const Center(child: CircularProgressIndicator())
              : _depots.isEmpty
              ? const Text('Depo bulunamadı')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _depots.length,
                    itemBuilder: (context, index) {
                      final depot = _depots[index];
                      final depotId = depot['id'] as int;
                      final address =
                          _depotAddresses[depotId] ??
                          depot['address'] ??
                          'Depo #$depotId';
                      return ListTile(
                        title: Text(address),
                        subtitle: Text(
                          'Kapasite: ${depot['capacityTon'] ?? ''} ton',
                        ),
                        onTap: () {
                          setState(() {
                            _selectedDepotId = depot['id'];
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Resim seçilemedi: $e');
    }
  }

  Future<void> _createProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      _showErrorSnackBar('Lütfen bir ürün fotoğrafı seçin');
      return;
    }

    if (_selectedDepotId == null) {
      _showErrorSnackBar('Lütfen bir depo seçin');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.createProductUrl),
      );

      // Authorization header ekle
      final authHeaders = await TokenService.getAuthHeadersForMultipart();
      request.headers.addAll(authHeaders);

      // Form-data alanları
      request.fields['name'] = productController.text.trim();
      request.fields['quantity_kg'] = amountController.text.trim();
      request.fields['price_per_kg'] = priceController.text.trim();
      request.fields['min_buy'] = minBuyController.text.trim();
      request.fields['id_depot'] = _selectedDepotId.toString();

      // Fotoğraf ekleme - Web ve mobil uyumlu
      final bytes = await _selectedImage!.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: _selectedImage!.name,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Yeni token varsa güncelle
      await TokenService.checkAndUpdateToken(response);

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessSnackBar('Ürün başarıyla oluşturuldu!');
        Navigator.pop(context, true);
      } else {
        _showErrorSnackBar('Ürün oluşturulamadı: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Bağlantı hatası: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    productController.dispose();
    amountController.dispose();
    priceController.dispose();
    minBuyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: ThemedAppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Yeni İlan Aç',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ürün adı',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: productController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : const Color(0xFFF5F5F5),
                  hintText: 'Örn: Elma',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ürün adı gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Miktar (kg)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : const Color(0xFFF5F5F5),
                  hintText: '400',
                  suffixText: 'kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Miktar gerekli';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Fiyat (₺/kg)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : const Color(0xFFF5F5F5),
                  hintText: '10',
                  suffixText: '₺/kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Fiyat gerekli';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Geçerli bir fiyat girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Minimum Alım (kg)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: minBuyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : const Color(0xFFF5F5F5),
                  hintText: '100',
                  suffixText: 'kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Minimum alım miktarı gerekli';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Ürün Fotoğrafı',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850]
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedImage == null
                          ? Colors.grey.shade300
                          : Colors.green,
                      width: 2,
                    ),
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fotoğraf Seç',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.network(
                                  _selectedImage!.path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.error, size: 50),
                                    );
                                  },
                                )
                              : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Depo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showDepotSelectionDialog,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850]
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDepotId == null
                              ? 'Depo seçin'
                              : _depotAddresses[_selectedDepotId] ??
                                    _depots.firstWhere(
                                      (d) => d['id'] == _selectedDepotId,
                                      orElse: () => {'id': _selectedDepotId},
                                    )['address'] ??
                                    'Depo #$_selectedDepotId',
                          style: TextStyle(
                            color: _selectedDepotId == null
                                ? Colors.grey[600]
                                : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      const Icon(Icons.location_on),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D563),
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'İlanı Oluştur',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
