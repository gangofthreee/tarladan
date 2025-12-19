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
  DateTime? _startDate, _endDate;
  List<dynamic> _trucks = [];
  bool _isLoadingTrucks = false, _isLoading = false;

  @override
  void initState() { super.initState(); _fetchTrucks(); }

  @override
  void dispose() { _priceController.dispose(); super.dispose(); }

  void _showMessage(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: isError ? Colors.red : kPrimaryColor));
  }

  Future<void> _fetchTrucks() async {
    setState(() => _isLoadingTrucks = true);
    try {
      _trucks = await TruckService.getTrucksByTrucker();
    } catch (e) {
      _showMessage('Hata: $e', isError: true);
    }
    if (mounted) setState(() => _isLoadingTrucks = false);
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate() || _selectedTruck == null || _startDate == null || _endDate == null) {
      _showMessage('Lütfen tüm alanları doldurunuz', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await TruckService.createTruckAd(
        truckId: int.parse(_selectedTruck!),
        startDate: formatApiDate(_startDate!),
        endDate: formatApiDate(_endDate!),
        pricePerKm: double.parse(_priceController.text),
      );
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessage('İlan yayınlandı!');
        Navigator.pop(context, true);
      } else {
        final msg = response.body.isNotEmpty ? (json.decode(response.body)['error'] ?? 'İlan oluşturulamadı') : 'İlan oluşturulamadı';
        _showMessage(msg, isError: true);
      }
    } catch (e) {
      _showMessage('Bağlantı hatası: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: ThemedAppBar(title: const Text('İlan Aç'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TruckerAdForm(
            formKey: _formKey,
            trucks: _trucks,
            isLoadingTrucks: _isLoadingTrucks,
            selectedTruck: _selectedTruck,
            startDate: _startDate,
            endDate: _endDate,
            priceController: _priceController,
            onTruckChanged: (v) => setState(() => _selectedTruck = v),
            onDateRangeSelected: (s, e) => setState(() { _startDate = s; _endDate = e; }),
          ),
          const SizedBox(height: 40),
          TruckerPrimaryButton(onPressed: _isLoading ? null : _handlePublish, label: 'İlanı Yayınla', isLoading: _isLoading),
        ]),
      ),
    );
  }
}
