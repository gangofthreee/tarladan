import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../config/api_config.dart';

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
  int _selectedDepotId = 1; // Default depo ID

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

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.createProductUrl),
      );

      // Form-data alanları
      request.fields['id'] = '1';
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
      SnackBar(
        content: Text(message),        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),        behavior: SnackBarBehavior.floating,
      ),
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
          style: TextStyle( fontWeight: FontWeight.bold),
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
                  fillColor: const Color(0xFFF5F5F5),
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
                  fillColor: const Color(0xFFF5F5F5),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
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
                  fillColor: const Color(0xFFF5F5F5),
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
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedImage == null ? Colors.grey.shade300 : Colors.green,
                      width: 2,
                    ),
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, 
                              size: 50, 
                              color: Colors.grey[600]
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Depo #$_selectedDepotId (Varsayılan)',
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    const Icon(Icons.location_on
                    ),
                  ],
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
