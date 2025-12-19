import 'package:flutter/material.dart';
import '../../services/customer_order_service.dart';
import '../../services/geocoding_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/customer_purchase_widgets.dart';

class CustomerPurchaseProductPage extends StatefulWidget {
  final int productId;
  final int depotId;
  final String productName;
  final String imageUrl;
  final double price;
  final String unit;
  final int availableQuantity;
  final double? depotLatitude;
  final double? depotLongitude;

  const CustomerPurchaseProductPage({
    super.key,
    required this.productId,
    required this.depotId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.unit,
    required this.availableQuantity,
    this.depotLatitude,
    this.depotLongitude,
  });

  @override
  State<CustomerPurchaseProductPage> createState() =>
      _CustomerPurchaseProductPageState();
}

class _CustomerPurchaseProductPageState
    extends State<CustomerPurchaseProductPage> {
  String _selectedLogistic = 'have_truck';
  String _selectedPayment = 'credit_card';
  bool _isLoading = false;
  int? _selectedTruckId;
  String? _selectedTruckerName;
  String? _selectedTruckVehicle;
  String? _selectedTruckPlate;

  // Controllers
  final _quantityController = TextEditingController(text: '1');
  final _licensePlateController = TextEditingController();
  final _capacityController = TextEditingController();
  final _modelController = TextEditingController();
  final _locFromController = TextEditingController();
  final _locToController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(() => setState(() {}));
    if (widget.depotLatitude != null && widget.depotLongitude != null) {
      _getDepotAddress();
    }
  }

  Future<void> _getDepotAddress() async {
    try {
      final address = await GeocodingService.getCityAndDistrict(widget.depotLatitude!, widget.depotLongitude!);
      if (mounted) setState(() => _locFromController.text = address);
    } catch (_) {
      if (mounted) setState(() => _locFromController.text = 'Depo konumu alınamadı');
    }
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _capacityController.dispose();
    _modelController.dispose();
    _locFromController.dispose();
    _locToController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _handleBuyAndPay() async {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    
    // Validation
    if (quantity <= 0) return _showSnack('Lütfen geçerli bir miktar giriniz');
    if (quantity > widget.availableQuantity) return _showSnack('Stok yetersiz! Max: ${widget.availableQuantity} kg');
    if (_locFromController.text.isEmpty || _locToController.text.isEmpty) return _showSnack('Lütfen konum bilgilerini girin');
    if (_selectedLogistic == 'no_truck' && _selectedTruckId == null) return _showSnack('Lütfen bir tır seçin');

    setState(() => _isLoading = true);

    final (success, message) = await CustomerOrderService.createOrder(
      productId: widget.productId,
      depotId: widget.depotId,
      truckId: _selectedTruckId ?? 1,
      locFrom: _locFromController.text,
      locTo: _locToController.text,
      quantityKg: quantity,
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        _showSnack('Sipariş başarıyla oluşturuldu!', color: const Color(0xFF4CAF50));
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        _showSnack(message ?? 'Bir hata oluştu');
      }
    }
  }

  void _showSnack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: ThemedAppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Satın Alma', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            PurchaseSummarySection(
              productName: widget.productName,
              price: widget.price,
              availableQuantity: widget.availableQuantity,
              imageUrl: widget.imageUrl,
              quantityController: _quantityController,
            ),
            const SizedBox(height: 30),
            PurchaseLogisticsSection(
              selectedLogistic: _selectedLogistic,
              onLogisticChanged: (v) => setState(() => _selectedLogistic = v!),
              plateController: _licensePlateController,
              capacityController: _capacityController,
              modelController: _modelController,
              selectedTruckId: _selectedTruckId,
              selectedTruckerName: _selectedTruckerName,
              selectedTruckVehicle: _selectedTruckVehicle,
              selectedTruckPlate: _selectedTruckPlate,
              onTruckSelected: (data) => setState(() {
                _selectedTruckId = data['truckId'];
                _selectedTruckerName = data['truckerName'];
                _selectedTruckVehicle = data['vehicle'];
                _selectedTruckPlate = data['plate'];
                _showSnack('Tır seçildi: $_selectedTruckerName', color: const Color(0xFF4CAF50));
              }),
            ),
            const SizedBox(height: 20),
            PurchaseLocationSection(
              locFromController: _locFromController,
              locToController: _locToController,
            ),
            const SizedBox(height: 30),
            PurchasePaymentSection(
              selectedPayment: _selectedPayment,
              onPaymentChanged: (v) => setState(() => _selectedPayment = v!),
            ),
            const SizedBox(height: 40),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() => SizedBox(
    width: double.infinity, height: 55,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _handleBuyAndPay,
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Satın Al ve Öde', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ),
  );
}


