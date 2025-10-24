import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../../config/api_config.dart';

class FarmerAdDetail extends StatefulWidget {
  final int productId;

  const FarmerAdDetail({super.key, required this.productId});

  @override
  State<FarmerAdDetail> createState() => _FarmerAdDetailState();
}

class _FarmerAdDetailState extends State<FarmerAdDetail> {
  Map<String, dynamic>? _product;
  bool _isLoading = true;
  bool _isEditMode = false;
  bool _isSaving = false;
  bool _hasChanges = false; // Değişiklik takibi için
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _minBuyController;

  XFile? _newImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _quantityController = TextEditingController();
    _priceController = TextEditingController();
    _minBuyController = TextEditingController();
    _fetchProductDetail();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _minBuyController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getProductDetailUrl(widget.productId)),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final productData = json.decode(decodedBody);
        setState(() {
          _product = productData;
          _nameController.text = productData['name'] ?? '';
          _quantityController.text = (productData['quantity_kg'] ?? 0)
              .toString();
          _priceController.text = (productData['price_per_kg'] ?? 0).toString();
          _minBuyController.text = (productData['min_buy'] ?? 0).toString();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Ürün bilgileri yüklenemedi';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Bağlantı hatası: $e';
        _isLoading = false;
      });
    }
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
          _newImage = image;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Fotoğraf seçilemedi: $e');
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse(ApiConfig.updateProductUrl(widget.productId)),
      );

      print('Updating product ${widget.productId}');
      print('Name: ${_nameController.text}');
      print('Quantity: ${_quantityController.text}');
      print('Price: ${_priceController.text}');
      print('Min Buy: ${_minBuyController.text}');
      print('Has new image: ${_newImage != null}');

      request.fields['name'] = _nameController.text;
      request.fields['quantity_kg'] = _quantityController.text;
      request.fields['price_per_kg'] = _priceController.text;
      request.fields['min_buy'] = _minBuyController.text;

      if (_newImage != null) {
        print('Adding photo to request: ${_newImage!.name}');
        if (kIsWeb) {
          final bytes = await _newImage!.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'photo',
              bytes,
              filename: _newImage!.name,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath('photo', _newImage!.path),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Ürün başarıyla güncellendi!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Kısa bir gecikme sonrası geri dön
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pop(context, true); // true ile geri dön, liste yenilensin
          }
        }
      } else {
        _showErrorSnackBar('Güncelleme başarısız: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Güncelleme hatası: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _nameController.text = _product!['name'] ?? '';
        _quantityController.text = (_product!['quantity_kg'] ?? 0).toString();
        _priceController.text = (_product!['price_per_kg'] ?? 0).toString();
        _minBuyController.text = (_product!['min_buy'] ?? 0).toString();
        _newImage = null;
      }
    });
  }

  Future<void> _deleteProduct() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.deleteProductUrl(widget.productId)),
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ürün başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pop(context, true); // true döndürerek liste güncellensin
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Silme başarısız: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('İlanı Sil'),
          content: Text(
            '${_product!['name']} ürününü silmek istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialog'u kapat
                _deleteProduct(); // Silme işlemini başlat
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _isEditMode ? _pickImage : null,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 250,
            decoration: const BoxDecoration(color: Color(0xFFFFE8D6)),
            child: _newImage != null
                ? FutureBuilder<Widget>(
                    future: _buildSelectedImage(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return snapshot.data!;
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  )
                : (_product!['image_path'] != null &&
                          _product!['image_path'].isNotEmpty
                      ? _buildNetworkImage()
                      : Center(
                          child: Icon(
                            Icons.image,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                        )),
          ),
          if (_isEditMode)
            Positioned(
              bottom: 16,
              right: 16,
              child: CircleAvatar(
                backgroundColor: const Color(0xFF1B5E20),
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Future<Widget> _buildSelectedImage() async {
    if (kIsWeb) {
      final bytes = await _newImage!.readAsBytes();
      return Image.memory(bytes, fit: BoxFit.cover);
    } else {
      return Image.file(File(_newImage!.path), fit: BoxFit.cover);
    }
  }

  Widget _buildNetworkImage() {
    String imagePath = _product!['image_path'];
    if (imagePath.startsWith('/app/uploads/')) {
      imagePath = imagePath.replaceFirst('/app/uploads/', '/uploads/');
    }
    final photoUrl = '${ApiConfig.baseUrl}$imagePath';

    return Image.network(
      photoUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 8),
              Text(
                'Fotoğraf yüklenemedi',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoField(
    String label,
    String value,
    TextEditingController controller, {
    String suffix = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        _isEditMode
            ? TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffix: Text(suffix),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Boş bırakılamaz';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Geçerli bir sayı girin';
                  }
                  return null;
                },
              )
            : Text(
                '$value$suffix',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context, _hasChanges),
          ),
          title: Text(
            _product?['name'] ?? 'İlan Detayları',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (!_isEditMode && _product != null)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black),
                onPressed: _toggleEditMode,
              ),
            if (_isEditMode)
              TextButton(
                onPressed: _toggleEditMode,
                child: const Text('İptal', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchProductDetail,
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSection(),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ürün Adı
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ürün Adı',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                _isEditMode
                                    ? TextFormField(
                                        controller: _nameController,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 8,
                                          ),
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Ürün adı boş bırakılamaz';
                                          }
                                          return null;
                                        },
                                      )
                                    : Text(
                                        _product!['name'] ?? 'N/A',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Diğer Bilgiler
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildInfoField(
                                    'Miktar',
                                    (_product!['quantity_kg'] ?? 0).toString(),
                                    _quantityController,
                                    suffix: ' kg',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildInfoField(
                                    'Fiyat',
                                    (_product!['price_per_kg'] ?? 0).toString(),
                                    _priceController,
                                    suffix: ' ₺/kg',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoField(
                              'Minimum Alım',
                              (_product!['min_buy'] ?? 0).toString(),
                              _minBuyController,
                              suffix: ' kg',
                            ),
                            const SizedBox(height: 24),
                            // Depo Konumu
                            const Text(
                              'Depo Konumu',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.map,
                                      size: 60,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Harita Görünümü',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Butonlar
                            if (_isEditMode)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _updateProduct,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B5E20),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Değişiklikleri Kaydet',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _toggleEditMode,
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Düzenle'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF1B5E20,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _showDeleteConfirmation,
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('İlanı Kaldır'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 24),
                          ],
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
