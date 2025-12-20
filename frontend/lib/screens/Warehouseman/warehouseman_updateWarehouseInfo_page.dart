import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../services/depot_service.dart';
import '../../widgets/location_picker_widget.dart';
import '../../widgets/warehouse_widgets.dart';
import '../../widgets/themed_scaffold.dart';

class WarehousemanUpdateWarehouseInfoPage extends StatefulWidget {
  final int depotId;
  final String warehouseName;
  final double? currentLatitude;
  final double? currentLongitude;
  final String currentSize;
  final String currentCapacity;
  final String currentPrice;

  const WarehousemanUpdateWarehouseInfoPage({
    super.key,
    required this.depotId,
    required this.warehouseName,
    this.currentLatitude,
    this.currentLongitude,
    this.currentSize = '',
    this.currentCapacity = '',
    this.currentPrice = '',
  });

  @override
  State<WarehousemanUpdateWarehouseInfoPage> createState() => _State();
}

class _State extends State<WarehousemanUpdateWarehouseInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _sizeCtrl;
  late TextEditingController _capCtrl;
  late TextEditingController _priceCtrl;
  bool _isLoading = false;
  LatLng? _loc;

  @override
  void initState() {
    super.initState();
    if (widget.currentLatitude != null && widget.currentLongitude != null) {
      _loc = LatLng(widget.currentLatitude!, widget.currentLongitude!);
    }
    _sizeCtrl = TextEditingController(text: widget.currentSize);
    _capCtrl = TextEditingController(text: widget.currentCapacity);
    _priceCtrl = TextEditingController(text: widget.currentPrice);
  }

  @override
  void dispose() { _sizeCtrl.dispose(); _capCtrl.dispose(); _priceCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await DepotService.updateDepot(
        depotId: widget.depotId,
        price: double.parse(_priceCtrl.text),
        capacityTon: double.parse(_capCtrl.text),
        sizeM2: double.parse(_sizeCtrl.text),
        latitude: _loc?.latitude,
        longitude: _loc?.longitude,
      );
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Güncelleme başarılı!'))); Navigator.pop(context, true); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      useGradientBackground: true,
      appBar: ThemedAppBar(
        title: const Text('Depo Güncelle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), centerTitle: true, elevation: 0, backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(key: _formKey, child: Column(children: [
          WarehouseLocationSelector(selectedLocation: _loc, onTap: () async {
              final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => LocationPickerWidget(initialLocation: _loc, onLocationSelected: (l, _) => setState(() => _loc = l))));
          }),
          const SizedBox(height: 20),
          WarehouseFormField(label: 'Boyut (m²)', controller: _sizeCtrl, hintText: 'Boyut giriniz', keyboardType: TextInputType.number, validator: (v) => (v == null || double.tryParse(v) == null) ? 'Geçersiz boyut' : null),
          const SizedBox(height: 20),
          WarehouseFormField(label: 'Kapasite (ton)', controller: _capCtrl, hintText: 'Kapasite giriniz', keyboardType: TextInputType.number, validator: (v) => (v == null || double.tryParse(v) == null) ? 'Geçersiz kapasite' : null),
          const SizedBox(height: 20),
          WarehouseFormField(label: 'Fiyat (₺)', controller: _priceCtrl, hintText: 'Fiyat giriniz', keyboardType: TextInputType.number, validator: (v) => (v == null || double.tryParse(v) == null) ? 'Geçersiz fiyat' : null),
          const SizedBox(height: 40),
          WarehouseActionButtons(onCancel: () => Navigator.pop(context), onSave: _submit, isLoading: _isLoading, saveLabel: 'Güncelle'),
        ])),
      ),
    );
  }
}
