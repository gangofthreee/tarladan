import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/truck_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/trucker_widgets.dart';

class TruckerTruckUpdatePage extends StatefulWidget {
  final Map<String, dynamic> ad;
  const TruckerTruckUpdatePage({super.key, required this.ad});
  @override
  State<TruckerTruckUpdatePage> createState() => _TruckerTruckUpdatePageState();
}

class _TruckerTruckUpdatePageState extends State<TruckerTruckUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _priceController;
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.ad['pricePerKm']?.toString() ?? '',
    );
    _parseStartDate();
  }

  void _parseStartDate() {
    try {
      final startDateStr = widget.ad['startDate']?.toString().split(' ')[0];
      if (startDateStr != null) {
        final parts = startDateStr.split('-');
        if (parts.length == 3) {
          _startDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      }
      final endDateStr = widget.ad['endDate']?.toString().split(' ')[0];
      if (endDateStr != null) {
        final parts = endDateStr.split('-');
        if (parts.length == 3) {
          _endDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final startDateStr =
          '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}';
      final endDateStr =
          '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}';

      final response = await TruckService.updateTruckAd(
        adId: widget.ad['id'],
        startDate: startDateStr,
        endDate: endDateStr,
        pricePerKm: double.parse(_priceController.text),
      );
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('İlan güncellendi')));
        Navigator.pop(context, true);
      } else {
        final errorMessage = response.body.isNotEmpty
            ? json.decode(response.body)['error'] ?? 'İlan güncellenemedi'
            : 'İlan güncellenemedi';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: ThemedAppBar(
        title: const Text('İlan Güncelle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TruckerSectionHeader(title: 'Araç Bilgisi'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          size: 24,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${widget.ad['truck']['model']} - ${widget.ad['truck']['plate']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TruckerDateRangePicker(
                    startDate: _startDate,
                    endDate: _endDate,
                    onDateRangeSelected: (start, end) => setState(() {
                      _startDate = start;
                      _endDate = end;
                    }),
                  ),
                  const SizedBox(height: 20),
                  TruckerFormField(
                    controller: _priceController,
                    hintText: 'Taban fiyat ₺/km veya ₺/iş',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen taban fiyat giriniz';
                      }
                      final price = double.tryParse(value);
                      if (price == null) {
                        return 'Lütfen geçerli bir sayı giriniz';
                      }
                      if (price <= 0) {
                        return 'Fiyat 0\'dan büyük olmalıdır';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            TruckerPrimaryButton(
              onPressed: _isLoading ? null : _handleUpdate,
              label: 'Güncelle',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
