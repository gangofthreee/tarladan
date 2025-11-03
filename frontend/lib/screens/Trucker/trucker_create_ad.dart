import 'package:flutter/material.dart';

class TruckerCreateAdPage extends StatefulWidget {
  const TruckerCreateAdPage({super.key});

  @override
  State<TruckerCreateAdPage> createState() => _TruckerCreateAdPageState();
}

class _TruckerCreateAdPageState extends State<TruckerCreateAdPage> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  
  String? _selectedTruck;
  DateTime? _selectedDateTime;

  // Örnek kayıtlı araçlar
  final List<Map<String, String>> trucks = [
    {'name': 'Volvo FH16 - 34 ABC 123', 'value': 'truck1'},
    {'name': 'Mercedes Actros - 06 XYZ 456', 'value': 'truck2'},
    {'name': 'Scania R500 - 35 DEF 789', 'value': 'truck3'},
  ];

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF4CAF50),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _handlePublish() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTruck == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen bir araç seçiniz'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen tarih ve saat seçiniz'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // API'ye ilan gönderme işlemi burada yapılacak
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İlan başarıyla yayınlandı!'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
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
          'İlan Aç',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Araç Seç Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedTruck,
                      hint: Text(
                        'Araç seç',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: trucks.map((truck) {
                        return DropdownMenuItem<String>(
                          value: truck['value'],
                          child: Text(
                            truck['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTruck = value;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tarih ve Saat Seçimi
                GestureDetector(
                  onTap: _selectDateTime,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDateTime == null
                              ? 'mm/dd/yyyy, --:-- --'
                              : _formatDateTime(_selectedDateTime!),
                          style: TextStyle(
                            color: _selectedDateTime == null
                                ? Colors.grey[400]
                                : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Taban Fiyat
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Taban fiyat ₺/km veya ₺/iş',
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
                      borderSide: const BorderSide(
                        color: Color(0xFF4CAF50),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen taban fiyat giriniz';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Lütfen geçerli bir sayı giriniz';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // İlanı Yayınla Butonu
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _handlePublish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'İlanı Yayınla',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
