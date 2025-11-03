import 'package:flutter/material.dart';
import 'customer_selectTruck_page.dart';

class CustomerPurchaseProductPage extends StatefulWidget {
  final String productName;
  final String imageUrl;
  final double price;
  final String unit;
  final int quantity;

  const CustomerPurchaseProductPage({
    super.key,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.unit,
    this.quantity = 10,
  });

  @override
  State<CustomerPurchaseProductPage> createState() =>
      _CustomerPurchaseProductPageState();
}

class _CustomerPurchaseProductPageState
    extends State<CustomerPurchaseProductPage> {
  String _selectedLogistic = 'have_truck';
  String _selectedPayment = 'credit_card';

  final _licensePlateController = TextEditingController();
  final _capacityController = TextEditingController();
  final _modelController = TextEditingController();

  @override
  void dispose() {
    _licensePlateController.dispose();
    _capacityController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _handleBuyAndPay() {
    if (_selectedLogistic == 'have_truck') {
      if (_licensePlateController.text.isEmpty ||
          _capacityController.text.isEmpty ||
          _modelController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen tüm araç bilgilerini doldurun'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // Payment processing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ödeme işleminiz başarıyla tamamlandı!'),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate back or to success page
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.price * widget.quantity;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Satın Alma',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              const Text(
                'Sipariş Özeti',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 20),

              // Product Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.productName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Miktar: ${widget.quantity} kg',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Logistics Section
              const Text(
                'Lojistik',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // Radio Options
              _buildRadioOption(
                value: 'have_truck',
                groupValue: _selectedLogistic,
                title: 'Tırım Var',
                onChanged: (value) {
                  setState(() {
                    _selectedLogistic = value!;
                  });
                },
              ),

              const SizedBox(height: 12),

              _buildRadioOption(
                value: 'no_truck',
                groupValue: _selectedLogistic,
                title: 'Tırım Yok',
                onChanged: (value) {
                  setState(() {
                    _selectedLogistic = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Conditional Fields for "Have Truck"
              if (_selectedLogistic == 'have_truck') ...[
                _buildTextField(
                  controller: _licensePlateController,
                  label: 'Plaka',
                  hint: 'Plaka giriniz',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _capacityController,
                  label: 'Kapasite',
                  hint: 'Kapasite giriniz',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _modelController,
                  label: 'Model',
                  hint: 'Model giriniz',
                ),
                const SizedBox(height: 20),
              ],

              // Go to Truck List Button
              if (_selectedLogistic == 'no_truck')
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final selectedTruckId = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomerSelectTruckPage(),
                        ),
                      );

                      if (selectedTruckId != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tır seçildi: $selectedTruckId'),
                            backgroundColor: const Color(0xFF4CAF50),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50).withOpacity(0.2),
                      foregroundColor: const Color(0xFF4CAF50),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tır Listesine Git',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              // Payment Section
              const Text(
                'Ödeme',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              _buildRadioOption(
                value: 'credit_card',
                groupValue: _selectedPayment,
                title: 'Kredi Kartı',
                onChanged: (value) {
                  setState(() {
                    _selectedPayment = value!;
                  });
                },
              ),

              const SizedBox(height: 40),

              // Buy and Pay Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleBuyAndPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Satın Al ve Öde',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String groupValue,
    required String title,
    required ValueChanged<String?> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value == groupValue
                ? const Color(0xFF4CAF50)
                : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: value == groupValue
                      ? const Color(0xFF4CAF50)
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: value == groupValue
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: value == groupValue
                      ? Colors.black87
                      : Colors.grey[600],
                  fontWeight: value == groupValue
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
