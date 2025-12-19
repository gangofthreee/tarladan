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
  late final TextEditingController _priceController;
  bool _isLoading = false;
  DateTime? _startDate, _endDate;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.ad['pricePerKm']?.toString() ?? '');
    _startDate = _parseDate(widget.ad['startDate']);
    _endDate = _parseDate(widget.ad['endDate']);
  }

  DateTime? _parseDate(dynamic dateStr) {
    if (dateStr == null) return null;
    try {
      final parts = dateStr.toString().split(' ')[0].split('-');
      return parts.length == 3 ? DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])) : null;
    } catch (_) { return null; }
  }

  @override
  void dispose() { _priceController.dispose(); super.dispose(); }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate() || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen tüm alanları doldurun')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await TruckService.updateTruckAd(
        adId: widget.ad['id'],
        startDate: formatApiDate(_startDate!),
        endDate: formatApiDate(_endDate!),
        pricePerKm: double.parse(_priceController.text),
      );
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İlan güncellendi')));
        Navigator.pop(context, true);
      } else {
        final msg = response.body.isNotEmpty ? (json.decode(response.body)['error'] ?? 'İlan güncellenemedi') : 'İlan güncellenemedi';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ThemedScaffold(
      appBar: ThemedAppBar(title: const Text('İlan Güncelle'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TruckerSectionHeader(title: 'Araç Bilgisi'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!, width: 1.5),
              ),
              child: Row(children: [
                Icon(Icons.local_shipping, size: 24, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                const SizedBox(width: 12),
                Expanded(child: Text('${widget.ad['truck']['model']} - ${widget.ad['truck']['plate']}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color))),
              ]),
            ),
            const SizedBox(height: 20),
            TruckerDateRangePicker(startDate: _startDate, endDate: _endDate, onDateRangeSelected: (s, e) => setState(() { _startDate = s; _endDate = e; })),
            const SizedBox(height: 20),
            TruckerFormField(controller: _priceController, hintText: 'Taban fiyat ₺/km', keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Fiyat giriniz';
                final p = double.tryParse(v!);
                return p == null ? 'Geçerli sayı giriniz' : p <= 0 ? 'Fiyat 0\'dan büyük olmalı' : null;
              }),
            const SizedBox(height: 40),
            TruckerPrimaryButton(onPressed: _isLoading ? null : _handleUpdate, label: 'Güncelle', isLoading: _isLoading),
          ]),
        ),
      ),
    );
  }
}
