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
  List<dynamic> _trucks = [];
  bool _isLoadingTrucks = false, _isLoading = false;
  String? _selectedTruckId;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.ad['pricePerKm']?.toString() ?? '',
    );
    _parseStartDate();
    _fetchTrucks();
  }

  void _parseStartDate() {
    try {
      final dateStr = widget.ad['startDate']?.toString().split(' ')[0];
      if (dateStr != null) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          _selectedDateTime = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      }
    } catch (e) {}
  }

  Future<void> _fetchTrucks() async {
    setState(() => _isLoadingTrucks = true);
    try {
      _trucks = await TruckService.getTrucksByTrucker();
    } catch (e) {}
    setState(() => _isLoadingTrucks = false);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate() ||
        _selectedTruckId == null ||
        _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final startDate =
          '${_selectedDateTime!.year}-${_selectedDateTime!.month.toString().padLeft(2, '0')}-${_selectedDateTime!.day.toString().padLeft(2, '0')}';
      final response = await TruckService.updateTruckAd(
        adId: widget.ad['id'],
        truckId: int.parse(_selectedTruckId!),
        startDate: startDate,
        endDate: startDate,
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
            TruckerAdForm(
              formKey: _formKey,
              trucks: _trucks,
              isLoadingTrucks: _isLoadingTrucks,
              selectedTruck: _selectedTruckId,
              selectedDateTime: _selectedDateTime,
              priceController: _priceController,
              onTruckChanged: (value) =>
                  setState(() => _selectedTruckId = value),
              onDateTimeSelected: (dateTime) =>
                  setState(() => _selectedDateTime = dateTime),
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
