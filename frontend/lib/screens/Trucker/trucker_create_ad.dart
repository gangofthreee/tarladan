import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/truck_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/trucker_widgets.dart';

class TruckerCreateAdPage extends StatefulWidget {
  const TruckerCreateAdPage({super.key});
  @override
  State<TruckerCreateAdPage> createState() => _TruckerCreateAdPageState();
}

class _TruckerCreateAdPageState extends State<TruckerCreateAdPage> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  String? _selectedTruck;
  DateTime? _selectedDateTime;
  List<dynamic> _trucks = [];
  bool _isLoadingTrucks = false, _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTrucks();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _fetchTrucks() async {
    setState(() => _isLoadingTrucks = true);
    try {
      _trucks = await TruckService.getTrucksByTrucker();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
    setState(() => _isLoadingTrucks = false);
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate() ||
        _selectedTruck == null ||
        _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurunuz')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final startDate = DateTime(
        _selectedDateTime!.year,
        _selectedDateTime!.month,
        _selectedDateTime!.day,
      );
      final endDate = startDate.add(const Duration(days: 30));
      final response = await TruckService.createTruckAd(
        truckId: int.parse(_selectedTruck!),
        startDate:
            '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
        endDate:
            '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
        pricePerKm: double.parse(_priceController.text),
      );
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('İlan yayınlandı!')));
        Navigator.pop(context, true);
      } else {
        final errorMessage = response.body.isNotEmpty
            ? json.decode(response.body)['error'] ?? 'İlan oluşturulamadı'
            : 'İlan oluşturulamadı';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Bağlantı hatası: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: ThemedAppBar(
        title: const Text('İlan Aç'),
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
              selectedTruck: _selectedTruck,
              selectedDateTime: _selectedDateTime,
              priceController: _priceController,
              onTruckChanged: (value) => setState(() => _selectedTruck = value),
              onDateTimeSelected: (dateTime) =>
                  setState(() => _selectedDateTime = dateTime),
            ),
            const SizedBox(height: 40),
            TruckerPrimaryButton(
              onPressed: _isLoading ? null : _handlePublish,
              label: 'İlanı Yayınla',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
