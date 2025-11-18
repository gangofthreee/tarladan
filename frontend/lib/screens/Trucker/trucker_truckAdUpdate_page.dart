import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../services/token_service.dart';

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
  late TextEditingController _priceController;

  List<dynamic> _trucks = [];
  bool _isLoadingTrucks = false;
  String? _selectedTruckId;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();

    // Mevcut araç bilgisini yükle
    _truckSelectionController = TextEditingController(
      text: widget.ad['truckModel'] != null && widget.ad['plate'] != null
          ? '${widget.ad['truckModel']} - ${widget.ad['plate']}'
          : '',
    );

    // Mevcut ilan verilerini yükle
    _priceController = TextEditingController(
      text: widget.ad['pricePerKm']?.toString() ?? '',
    );

    // Mevcut tarihi parse et (varsa)
    if (widget.ad['startDate'] != null &&
        widget.ad['startDate'].toString().isNotEmpty) {
      try {
        // Backend'den gelen format: yyyy-MM-dd veya yyyy-MM-dd HH:mm:ss
        final dateStr = widget.ad['startDate'].toString().split(' ')[0];
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          _selectedDateTime = DateTime(
            int.parse(parts[0]), // year
            int.parse(parts[1]), // month
            int.parse(parts[2]), // day
          );
        }
      } catch (e) {
        print('Tarih parse hatası: $e');
      }
    }

    _fetchTrucks();
  }

  Future<void> _fetchTrucks() async {
    setState(() {
      _isLoadingTrucks = true;
    });

    try {
      final authHeaders = await TokenService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.getTrucksByTruckerUrl),
        headers: authHeaders,
      );

      await TokenService.checkAndUpdateToken(response);

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);
        setState(() {
          _trucks = dataList;
          _isLoadingTrucks = false;
        });
      } else {
        setState(() {
          _isLoadingTrucks = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingTrucks = false;
      });
    }
  }

  @override
  void dispose() {
    _truckSelectionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF4CAF50),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }

  void _showTruckSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tır Seç'),
          content: _isLoadingTrucks
              ? const Center(child: CircularProgressIndicator())
              : _trucks.isEmpty
              ? const Text('Araç bulunamadı')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _trucks.length,
                    itemBuilder: (context, index) {
                      final truck = _trucks[index];
                      return ListTile(
                        title: Text(truck['vehicle'] ?? 'Araç'),
                        subtitle: Text(truck['plate'] ?? ''),
                        onTap: () {
                          setState(() {
                            _selectedTruckId = truck['id'].toString();
                            _truckSelectionController.text =
                                '${truck['vehicle']} - ${truck['plate']}';
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

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      // Validasyonlar
      if (_selectedTruckId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lütfen bir araç seçin')));
        return;
      }

      if (_selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen tarih ve saat seçin')),
        );
        return;
      }

      if (_priceController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lütfen fiyat girin')));
        return;
      }

      try {
        final adId = widget.ad['id'];
        final authHeaders = await TokenService.getAuthHeaders();

        // Backend'e gönderilecek tarih formatı: yyyy-MM-dd
        final startDate =
            '${_selectedDateTime!.year}-${_selectedDateTime!.month.toString().padLeft(2, '0')}-${_selectedDateTime!.day.toString().padLeft(2, '0')}';
        final endDate = startDate; // Aynı gün için

        final requestBody = {
          'truckId': int.parse(_selectedTruckId!),
          'startDate': startDate,
          'endDate': endDate,
          'pricePerKm': double.parse(_priceController.text),
        };

        print('🔄 Updating ad with ID: $adId');
        print('📦 Request body: ${json.encode(requestBody)}');
        print('🔗 URL: ${ApiConfig.updateTruckAdUrl(adId)}');

        final response = await http.patch(
          Uri.parse(ApiConfig.updateTruckAdUrl(adId)),
          headers: authHeaders,
          body: json.encode(requestBody),
        );

        print('📥 Response status: ${response.statusCode}');
        print('📥 Response body: ${response.body}');

        await TokenService.checkAndUpdateToken(response);

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('İlan başarıyla güncellendi')),
            );
            Navigator.pop(context, true); // true dönerek listeyi yenile
          }
        } else {
          throw Exception(
            'İlan güncellenemedi: ${response.statusCode} - ${response.body}',
          );
        }
      } catch (e) {
        print('❌ Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
        }
      }
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
                GestureDetector(
                  onTap: _selectDateTime,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDateTime == null
                              ? 'mm/dd/yyyy, --:-- --'
                              : _formatDateTime(_selectedDateTime!),
                          style: TextStyle(
                            color: _selectedDateTime == null
                                ? Colors.grey[400]
                                : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
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
