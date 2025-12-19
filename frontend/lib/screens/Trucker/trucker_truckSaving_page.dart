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
  final _picker = ImagePicker();
  XFile? _photoFile;
  Uint8List? _photoBytes;
  bool _isLoading = false;

  @override
  void dispose() {
    _brandModelController.dispose();
    _plateController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _showMessage(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: isError ? Colors.red : kPrimaryColor,
    ));
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;
      final bytes = await pickedFile.readAsBytes();
      final compressed = await ImageService.compressImage(bytes);
      setState(() { _photoFile = pickedFile; _photoBytes = compressed; });
      _showMessage('Fotoğraf yüklendi');
    } catch (e) {
      _showMessage('Resim hatası: $e', isError: true);
    }
  }

  void _removeImage() => setState(() { _photoFile = null; _photoBytes = null; });

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate() || _photoBytes == null || _photoFile == null) {
      _showMessage('Lütfen tüm alanları doldurunuz', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await TruckService.createTruck(
        vehicle: _brandModelController.text,
        capacityTon: _capacityController.text,
        plate: _plateController.text,
        photoFile: _photoFile!,
        photoBytes: _photoBytes!,
      );
      if (mounted) {
        _showMessage('Araç kaydedildi');
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: ThemedAppBar(title: const Text('Araç Kaydet'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
      body: _isLoading
          ? const TruckerLoadingWidget(message: 'Kaydediliyor...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                TruckerTruckForm(formKey: _formKey, brandModelController: _brandModelController, plateController: _plateController, capacityController: _capacityController),
                const SizedBox(height: 30),
                TruckerSingleImageUploader(imageBytes: _photoBytes, onPickImage: _pickImage, onRemoveImage: _removeImage),
                const SizedBox(height: 30),
                TruckerPrimaryButton(label: 'Kaydet', onPressed: _handleSave),
              ]),
            ),
    );
  }
}
