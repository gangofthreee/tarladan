import 'package:flutter/material.dart';
import '../../services/geocoding_service.dart';
import '../../screens/Customer/customer_selectTruck_page.dart';
import '../location_picker_widget.dart';

// Private utility components
class _PurchaseSectionTitle extends StatelessWidget {
  final String title;
  const _PurchaseSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color));
  }
}

class _PurchaseInfoText extends StatelessWidget {
  final String text;
  const _PurchaseInfoText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)));
  }
}

class _PurchaseTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool readOnly;

  const _PurchaseTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        IgnorePointer(
          ignoring: readOnly,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------------------------------
// PUBLIC SECTIONS
// --------------------------------------------------------------------------------

class PurchaseSummarySection extends StatelessWidget {
  final String productName;
  final double price;
  final int availableQuantity;
  final int minBuy;
  final String imageUrl;
  final TextEditingController quantityController;

  const PurchaseSummarySection({
    super.key,
    required this.productName,
    required this.price,
    required this.availableQuantity,
    this.minBuy = 1,
    required this.imageUrl,
    required this.quantityController,
  });

  @override
  Widget build(BuildContext context) {
    final quantity = double.tryParse(quantityController.text) ?? 0;
    final totalPrice = price * quantity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PurchaseSectionTitle('Sipariş Özeti'),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    _PurchaseInfoText('Birim Fiyat: $price ₺/kg'),
                    _PurchaseInfoText('Stok: $availableQuantity kg'),
                    if (minBuy > 1) _PurchaseInfoText('Min. Alım: $minBuy kg'),
                    const SizedBox(height: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const _PurchaseInfoText('Miktar'),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 80,
                        height: 45,
                        child: TextField(
                          controller: quantityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Text('Toplam: ${totalPrice.toStringAsFixed(2)} ₺', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 100, height: 100, color: Colors.grey[300], child: const Icon(Icons.image_not_supported, color: Colors.grey))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PurchaseLogisticsSection extends StatelessWidget {
  final String selectedLogistic;
  final ValueChanged<String?> onLogisticChanged;
  final TextEditingController plateController;
  final TextEditingController capacityController;
  final TextEditingController modelController;
  
  // Truck Selection State
  final int? selectedTruckId;
  final String? selectedTruckerName;
  final String? selectedTruckVehicle;
  final String? selectedTruckPlate;
  final Function(Map<String, dynamic>) onTruckSelected;

  const PurchaseLogisticsSection({
    super.key,
    required this.selectedLogistic,
    required this.onLogisticChanged,
    required this.plateController,
    required this.capacityController,
    required this.modelController,
    required this.onTruckSelected,
    this.selectedTruckId,
    this.selectedTruckerName,
    this.selectedTruckVehicle,
    this.selectedTruckPlate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PurchaseSectionTitle('Lojistik'),
        const SizedBox(height: 16),
        _buildRadioOption(context, 'have_truck', 'Tırım Var'),
        const SizedBox(height: 12),
        _buildRadioOption(context, 'no_truck', 'Tırım Yok'),
        const SizedBox(height: 20),
        if (selectedLogistic == 'have_truck') ...[
          _PurchaseTextField(controller: plateController, label: 'Plaka', hint: 'Plaka giriniz'),
          const SizedBox(height: 16),
          _PurchaseTextField(controller: capacityController, label: 'Kapasite', hint: 'Kapasite giriniz', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _PurchaseTextField(controller: modelController, label: 'Model', hint: 'Model giriniz'),
        ],
        if (selectedLogistic == 'no_truck') _buildTruckSelectionButton(context),
      ],
    );
  }

  Widget _buildRadioOption(BuildContext context, String value, String title) {
    bool selected = value == selectedLogistic;
    return GestureDetector(
      onTap: () => onLogisticChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF4CAF50) : Colors.grey[300]!, width: 2),
        ),
        child: Row(children: [
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? const Color(0xFF4CAF50) : Colors.grey[400]),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, color: Theme.of(context).textTheme.bodyLarge?.color)),
        ]),
      ),
    );
  }

  Widget _buildTruckSelectionButton(BuildContext context) {
    if (selectedTruckId != null) {
      // Show selected truck info in a card
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Araç: $selectedTruckVehicle', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 6),
            Text('Plaka: $selectedTruckPlate', style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium?.color)),
            const SizedBox(height: 6),
            Text('Araç Sahibi: $selectedTruckerName', style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium?.color)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final data = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerSelectTruckPage()));
                  if (data != null) onTruckSelected(data);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Değiştir', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }
    
    return SizedBox(
      width: double.infinity, height: 50,
      child: ElevatedButton(
        onPressed: () async {
          final data = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerSelectTruckPage()));
          if (data != null) onTruckSelected(data);
        },
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50).withOpacity(0.2), foregroundColor: const Color(0xFF4CAF50), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('Tır Listesine Git', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class PurchaseLocationSection extends StatefulWidget {
  final TextEditingController locFromController;
  final TextEditingController locToController;

  const PurchaseLocationSection({
    super.key,
    required this.locFromController,
    required this.locToController,
  });

  @override
  State<PurchaseLocationSection> createState() => _PurchaseLocationSectionState();
}

class _PurchaseLocationSectionState extends State<PurchaseLocationSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PurchaseTextField(controller: widget.locFromController, label: 'Nereden', hint: 'Konum yükleniyor...', readOnly: true),
        const SizedBox(height: 16),
        _PurchaseTextField(controller: widget.locToController, label: 'Nereye', hint: 'Örn: İzmir / Bornova'),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationPickerWidget(
                    onLocationSelected: (latlng, address) async {
                      final properAddress = await GeocodingService.getCityAndDistrict(latlng.latitude, latlng.longitude);
                      if (mounted) setState(() => widget.locToController.text = properAddress);
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.map_outlined), label: const Text('Haritadan Seç'),
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF4CAF50), side: const BorderSide(color: Color(0xFF4CAF50)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
      ],
    );
  }
}

class PurchasePaymentSection extends StatelessWidget {
  final String selectedPayment;
  final ValueChanged<String?> onPaymentChanged;

  const PurchasePaymentSection({super.key, required this.selectedPayment, required this.onPaymentChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PurchaseSectionTitle('Ödeme'),
        const SizedBox(height: 16),
        _buildRadioOption(context, 'credit_card', 'Kredi Kartı'),
      ],
    );
  }

  Widget _buildRadioOption(BuildContext context, String value, String title) {
    bool selected = value == selectedPayment;
    return GestureDetector(
      onTap: () => onPaymentChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF4CAF50) : Colors.grey[300]!, width: 2),
        ),
        child: Row(children: [
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? const Color(0xFF4CAF50) : Colors.grey[400]),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, color: Theme.of(context).textTheme.bodyLarge?.color)),
        ]),
      ),
    );
  }
}
