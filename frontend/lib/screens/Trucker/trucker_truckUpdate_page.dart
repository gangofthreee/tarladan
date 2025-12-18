import 'package:flutter/material.dart';
import '../../services/truck_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/trucker_widgets.dart';

class TruckerTruckUpdatePage extends StatefulWidget {
  final Map<String, dynamic> truck;
  const TruckerTruckUpdatePage({super.key, required this.truck});
  @override
  State<TruckerTruckUpdatePage> createState() => _TruckerTruckUpdatePageState();
}

class _TruckerTruckUpdatePageState extends State<TruckerTruckUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandModelController;
  late TextEditingController _plateController;
  late TextEditingController _capacityController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _brandModelController = TextEditingController(
      text: widget.truck['brandModel'] ?? '',
    );
    _plateController = TextEditingController(text: widget.truck['plate'] ?? '');
    _capacityController = TextEditingController(
      text: widget.truck['trailerCapacity']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _brandModelController.dispose();
    _plateController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await TruckService.updateTruck(
        truckId: widget.truck['truckId'],
        vehicle: _brandModelController.text,
        capacityTon: _capacityController.text,
        plate: _plateController.text,

      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Araç güncellendi')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Güncelleme hatası: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: ThemedAppBar(
        title: const Text('Araç Güncelle'),
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
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: TruckerPrimaryButton(
                          label: 'İptal',
                          onPressed: () => Navigator.pop(context),
                          backgroundColor: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TruckerPrimaryButton(
                          label: 'Güncelle',
                          onPressed: _handleUpdate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
