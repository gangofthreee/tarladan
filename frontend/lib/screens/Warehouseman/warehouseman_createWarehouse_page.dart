import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../services/depot_service.dart';
import '../../widgets/location_picker_widget.dart';
import '../../widgets/warehouse_widgets.dart';
import '../../widgets/themed_scaffold.dart';

class WarehousemanCreateWarehousePage extends StatefulWidget {
  final int depoOwnerId;
  const WarehousemanCreateWarehousePage({super.key, required this.depoOwnerId});

  @override
  State<WarehousemanCreateWarehousePage> createState() => _WarehousemanCreateWarehousePageState();
}

class _WarehousemanCreateWarehousePageState extends State<WarehousemanCreateWarehousePage> {
  final _formKey = GlobalKey<FormState>();
  final _sizeCtrl = TextEditingController();
  final _capCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  bool _isLoading = false;
  LatLng? _loc;

  @override
  void dispose() {
    _sizeCtrl.dispose(); _capCtrl.dispose(); _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_loc == null) return _snack('Lütfen konum seçin', isError: true);

    setState(() => _isLoading = true);
    try {
      await DepotService.createDepot(
        latitude: _loc!.latitude,
        longitude: _loc!.longitude,
        sizeM2: double.parse(_sizeCtrl.text),
        capacityTon: double.parse(_capCtrl.text),
        price: double.parse(_priceCtrl.text),
      );
      if (mounted) {
        _snack('Depo başarıyla eklendi!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _snack(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      useGradientBackground: true,
      appBar: ThemedAppBar(
        title: const Text('Depo Ekle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        centerTitle: true, elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              WarehouseLocationSelector(
                selectedLocation: _loc,
                onTap: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => LocationPickerWidget(initialLocation: _loc, onLocationSelected: (l, _) => setState(() => _loc = l))));
                },
              ),
              const SizedBox(height: 20),
              WarehouseFormField(label: 'Boyut (m²)', controller: _sizeCtrl, hintText: 'Boyut giriniz', keyboardType: TextInputType.number, 
                validator: (v) => (v == null || double.tryParse(v) == null || double.parse(v) <= 0) ? 'Geçersiz boyut' : null),
              const SizedBox(height: 20),
              WarehouseFormField(label: 'Kapasite (ton)', controller: _capCtrl, hintText: 'Kapasite giriniz', keyboardType: TextInputType.number,
                 validator: (v) => (v == null || double.tryParse(v) == null || double.parse(v) <= 0) ? 'Geçersiz kapasite' : null),
              const SizedBox(height: 20),
              WarehouseFormField(label: 'Fiyat (₺)', controller: _priceCtrl, hintText: 'Fiyat giriniz', keyboardType: TextInputType.number,
                 validator: (v) => (v == null || double.tryParse(v) == null || double.parse(v) <= 0) ? 'Geçersiz fiyat' : null),
              const SizedBox(height: 40),
              WarehouseActionButtons(onCancel: () => Navigator.pop(context), onSave: _submit, isLoading: _isLoading, saveLabel: 'Ekle'),
            ],
          ),
        ),
      ),
    );
  }
}
