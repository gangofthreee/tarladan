import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/truck_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/trucker_widgets.dart';

class TruckerTruckSavingPage extends StatefulWidget {
  const TruckerTruckSavingPage({super.key});
  @override
  State<TruckerTruckSavingPage> createState() => _TruckerTruckSavingPageState();
}

class _TruckerTruckSavingPageState extends State<TruckerTruckSavingPage> {
  final _formKey = GlobalKey<FormState>();
  final _brandModelController = TextEditingController();
  final _plateController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  XFile? _photoFile;
  Uint8List? _photoBytes;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _brandModelController.dispose();
    _plateController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;
      final bytes = await pickedFile.readAsBytes();
      final compressed = await ImageService.compressImage(bytes);
      setState(() {
        _photoFile = pickedFile;
        _photoBytes = compressed;
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fotoğraf yüklendi'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Resim hatası: $e')));
    }
  }

  void _removeImage() => setState(() {
    _photoFile = null;
    _photoBytes = null;
  });

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate() ||
        _photoBytes == null ||
        _photoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurunuz')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await TruckService.createTruck(
        vehicle: _brandModelController.text,
        capacityTon: _capacityController.text,
        plate: _plateController.text,
        basePrice: _priceController.text,
        photoFile: _photoFile!,
        photoBytes: _photoBytes!,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Araç kaydedildi')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Kayıt hatası: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: ThemedAppBar(
        title: const Text('Araç Kaydet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TruckerTruckForm(
                    formKey: _formKey,
                    brandModelController: _brandModelController,
                    plateController: _plateController,
                    capacityController: _capacityController,
                    priceController: _priceController,
                  ),
                  const SizedBox(height: 30),
                  TruckerSingleImageUploader(
                    imageBytes: _photoBytes,
                    onPickImage: _pickImage,
                    onRemoveImage: _removeImage,
                  ),
                  const SizedBox(height: 30),
                  TruckerPrimaryButton(label: 'Kaydet', onPressed: _handleSave),
                ],
              ),
            ),
    );
  }
}
