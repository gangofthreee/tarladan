import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../config/api_config.dart';
import '../../services/farmer_product_service.dart';
import '../../services/geocoding_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/farmer_widgets.dart';

class FarmerAdDetail extends StatefulWidget {
  final int productId;
  final bool canEdit; // Yeni parametre: true ise düzenleme/silme yapılabilir
  
  const FarmerAdDetail({super.key, required this.productId, this.canEdit = true});
  
  @override
  State<FarmerAdDetail> createState() => _FarmerAdDetailState();
}

class _FarmerAdDetailState extends State<FarmerAdDetail> {
  Map<String, dynamic>? _product;
  bool _isLoading = true, _isEditMode = false, _isSaving = false;
  String? _errorMessage, _depotAddress;
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(), _qtyCtrl = TextEditingController(), _priceCtrl = TextEditingController(), _minCtrl = TextEditingController();
  XFile? _newImage;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _nameCtrl.dispose(); _qtyCtrl.dispose(); _priceCtrl.dispose(); _minCtrl.dispose(); super.dispose(); }

  String _val(String k) => (_product![k] ?? 0).toString();

  Future<void> _load() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    final data = await FarmerProductService.fetchProduct(widget.productId);
    if (data != null) {
      setState(() { _product = data; _nameCtrl.text = data['name'] ?? ''; _qtyCtrl.text = _val('quantity_kg'); _priceCtrl.text = _val('price_per_kg'); _minCtrl.text = _val('min_buy'); _isLoading = false; });
      if (data['depot_latitude'] != null) GeocodingService.getCityAndDistrict(data['depot_latitude'], data['depot_longitude']).then((a) { if (mounted) setState(() => _depotAddress = a); }).catchError((_) {});
    } else {
      setState(() { _errorMessage = 'Yüklenemedi'; _isLoading = false; });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final (success, msg) = await FarmerProductService.updateProduct(widget.productId, {'name': _nameCtrl.text, 'quantity_kg': _qtyCtrl.text, 'price_per_kg': _priceCtrl.text, 'min_buy': _minCtrl.text}, _newImage);
    if (mounted) {
      if (success) {
        _msg('İlan güncellendi', true);
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) Navigator.pop(context, true);
      } else {
        _handleError(msg);
      }
      setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _isSaving = true);
    final (success, msg) = await FarmerProductService.deleteProduct(widget.productId);
    if (mounted) {
      if (success) {
        _msg('İlan silindi', true);
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) Navigator.pop(context, true);
      } else {
        _handleError(msg, isDelete: true);
      }
      setState(() => _isSaving = false);
    }
  }

  void _handleError(String? msg, {bool isDelete = false}) {
    if (msg != null && (msg.contains('403') || msg.toLowerCase().contains('authorized'))) {
      if (isDelete) {
        _msg('Bu ilana ait sipariş bulunduğu için silinemiyor.', false);
      } else {
        _msg('Yetki hatası! Lütfen tekrar giriş yapın.', false);
      }
    } else {
      _msg(msg ?? 'İşlem başarısız', false);
    }
  }

  void _toggle() => setState(() { _isEditMode = !_isEditMode; if (!_isEditMode) { _nameCtrl.text = _product!['name'] ?? ''; _qtyCtrl.text = _val('quantity_kg'); _priceCtrl.text = _val('price_per_kg'); _minCtrl.text = _val('min_buy'); _newImage = null; } });

  void _msg(String m, bool ok) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: ok ? Colors.green : Colors.red)); }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false, onPopInvokedWithResult: (d, _) { if (!d) Navigator.pop(context); },
    child: ThemedScaffold(
      useGradientBackground: true,
      appBar: ThemedAppBar(elevation: 0, backgroundColor: Colors.transparent, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), title: Text(_product?['name'] ?? 'Detay', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold))),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: FarmerConstants.primaryColor)) : _errorMessage != null ? FarmerErrorState(message: _errorMessage!, onRetry: _load) : _form(),
    ),
  );

  Widget _form() => Form(key: _formKey, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    FarmerProductImageSection(imagePath: _product!['image_path'], baseUrl: ApiConfig.baseUrl, isEditMode: widget.canEdit && _isEditMode, onTap: widget.canEdit ? () async { final i = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1080, imageQuality: 85); if (i != null) setState(() => _newImage = i); } : null, selectedImageWidget: _newImage != null ? FutureBuilder<Widget>(future: _img(), builder: (c, s) => s.hasData ? s.data! : const Center(child: CircularProgressIndicator(color: FarmerConstants.primaryColor))) : null),
    Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FarmerEditableField(label: 'Ürün Adı', value: _product!['name'] ?? '', controller: _nameCtrl, isEditMode: widget.canEdit && _isEditMode, isNumeric: false),
      const SizedBox(height: 16),
      Row(children: [Expanded(child: FarmerEditableField(label: 'Miktar', value: _val('quantity_kg'), controller: _qtyCtrl, isEditMode: widget.canEdit && _isEditMode, suffix: ' kg')), const SizedBox(width: 16), Expanded(child: FarmerEditableField(label: 'Fiyat', value: _val('price_per_kg'), controller: _priceCtrl, isEditMode: widget.canEdit && _isEditMode, suffix: ' ₺/kg'))]),
      const SizedBox(height: 16),
      FarmerEditableField(label: 'Min. Alım', value: _val('min_buy'), controller: _minCtrl, isEditMode: widget.canEdit && _isEditMode, suffix: ' kg'),
      const SizedBox(height: 24), const FarmerSectionTitle(title: 'Depo Konumu'), const SizedBox(height: 12),
      _product!['depot_latitude'] != null ? FarmerDepotMapWidget(latitude: _product!['depot_latitude'], longitude: _product!['depot_longitude'], address: _depotAddress) : const FarmerNoLocationPlaceholder(),
      const SizedBox(height: 24),
      // Sadece canEdit true ise düzenleme butonlarını göster
      if (widget.canEdit)
        FarmerDetailButtons(isEditMode: _isEditMode, isSaving: _isSaving, onEdit: _toggle, onSave: _save, onDelete: () => FarmerDeleteDialog.show(context, productName: _product!['name'] ?? 'Ürün', onConfirm: _delete)),
      const SizedBox(height: 24),
    ])),
  ])));

  Future<Widget> _img() async => kIsWeb ? Image.memory(await _newImage!.readAsBytes(), fit: BoxFit.cover) : Image.file(File(_newImage!.path), fit: BoxFit.cover);
}
