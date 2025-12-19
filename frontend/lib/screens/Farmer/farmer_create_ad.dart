import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../services/farmer_product_service.dart';
import '../../services/depot_service.dart';
import '../../services/geocoding_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/farmer_widgets.dart';

class FarmerCreateAd extends StatefulWidget {
  const FarmerCreateAd({super.key});
  @override
  State<FarmerCreateAd> createState() => _FarmerCreateAdState();
}

class _FarmerCreateAdState extends State<FarmerCreateAd> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(), _qty = TextEditingController(), _price = TextEditingController(), _min = TextEditingController();
  XFile? _img;
  bool _loading = false;
  List<dynamic> _depots = [];
  int? _depotId;
  final Map<int, String> _depotAddr = {};

  @override
  void initState() { super.initState(); _loadDepots(); }
  @override
  void dispose() { _name.dispose(); _qty.dispose(); _price.dispose(); _min.dispose(); super.dispose(); }

  Future<void> _loadDepots() async {
    final depots = await DepotService.getAllDepots();
    _depots = depots;
    for (var d in _depots) {
      if (d['latitude'] != null) {
        GeocodingService.getCityAndDistrict(d['latitude'], d['longitude'])
            .then((a) { if (mounted) setState(() => _depotAddr[d['id']] = a); })
            .catchError((_) {});
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) { _msg('Lütfen hatalı alanları düzeltin'); return; }
    if (_img == null) { _msg('Lütfen bir ürün fotoğrafı seçin'); return; }
    if (_depotId == null) { _msg('Lütfen ürünü teslim edeceğiniz depoyu seçin'); return; }
    
    setState(() => _loading = true);
    
    final fields = {
      'name': _name.text.trim(),
      'quantity_kg': _qty.text.trim().replaceAll(',', '.'),
      'price_per_kg': _price.text.trim().replaceAll(',', '.'),
      'min_buy': _min.text.trim().replaceAll(',', '.'),
    };

    final (success, error, statusCode) = await FarmerProductService.createProduct(fields, _img!, _depotId!);
    
    if (mounted) {
      setState(() => _loading = false);
      if (success) {
        _msg('İlan oluşturuldu', ok: true);
        Navigator.pop(context, true);
      } else if (statusCode == 401 || statusCode == 403) {
        _msg('Oturum süreniz doldu. Lütfen tekrar giriş yapın.');
      } else {
        _msg(error ?? 'Bir hata oluştu');
      }
    }
  }

  void _msg(String m, {bool ok = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: ok ? Colors.green : Colors.red));
  void _pickDepot() => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Depo Seç'), content: _depots.isEmpty ? const Text('Yok') : SizedBox(width: double.maxFinite, child: ListView(shrinkWrap: true, children: _depots.map((d) => ListTile(title: Text(_depotAddr[d['id']] ?? 'Depo #${d['id']}'), subtitle: Text('${d['capacityTon'] ?? 0} ton'), onTap: () { setState(() => _depotId = d['id']); Navigator.pop(context); })).toList()))));
  InputDecoration _deco(String h, {String? s}) => InputDecoration(filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : const Color(0xFFF5F5F5), hintText: h, suffixText: s, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none));

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : const Color(0xFFF5F5F5);
    return ThemedScaffold(
      appBar: ThemedAppBar(elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), title: const Text('Yeni İlan', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
        _f('Ürün adı', TextFormField(controller: _name, decoration: _deco('Örn: Elma'), validator: (v) => v == null || v.isEmpty ? 'Ürün adı boş olamaz' : null)),
        _f('Miktar (kg)', TextFormField(controller: _qty, keyboardType: TextInputType.number, decoration: _deco('400', s: 'kg'), validator: (v) => _valNum(v, 'Miktar'))),
        _f('Fiyat (₺/kg)', TextFormField(controller: _price, keyboardType: TextInputType.number, decoration: _deco('10', s: '₺/kg'), validator: (v) => _valNum(v, 'Fiyat'))),
        _f('Min. Alım (kg)', TextFormField(controller: _min, keyboardType: TextInputType.number, decoration: _deco('100', s: 'kg'), validator: (v) => _valNum(v, 'Min. Alım'))),
        _f('Fotoğraf', GestureDetector(onTap: () async { final i = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1920, imageQuality: 85); if (i != null) setState(() => _img = i); }, child: Container(height: 180, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _img != null ? Colors.green : Colors.grey, width: 2)), child: _img == null ? Center(child: Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey[600])) : ClipRRect(borderRadius: BorderRadius.circular(10), child: kIsWeb ? Image.network(_img!.path, fit: BoxFit.cover) : Image.file(File(_img!.path), fit: BoxFit.cover))))),
        _f('Depo', GestureDetector(onTap: _pickDepot, child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green)), child: Row(children: [Expanded(child: Text(_depotId == null ? 'Depo seçin' : _depotAddr[_depotId] ?? 'Depo #$_depotId')), const Icon(Icons.location_on)])))),
        const SizedBox(height: 16),
        SizedBox(height: 56, child: ElevatedButton(onPressed: _loading ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: FarmerConstants.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('İlanı Oluştur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)))),
      ])),
    );
  }

  Widget _f(String l, Widget w) => Padding(padding: const EdgeInsets.only(bottom: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)), const SizedBox(height: 8), w]));
  String? _valNum(String? v, String f) {
    if (v == null || v.isEmpty) return '$f boş olamaz';
    final n = double.tryParse(v.replaceAll(',', '.'));
    if (n == null) return 'Geçersiz sayı';
    if (n <= 0) return '$f 0\'dan büyük olmalı';
    return null;
  }
}
