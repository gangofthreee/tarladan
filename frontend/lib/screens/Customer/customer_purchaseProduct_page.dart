import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/api_config.dart';
import '../../services/token_service.dart';
import 'customer_selectTruck_page.dart';

import '../../widgets/themed_scaffold.dart';

class CustomerPurchaseProductPage extends StatefulWidget {
  final int productId;
  final int depotId;
  final String productName;
  final String imageUrl;
  final double price;
  final String unit;
  final int quantity;
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
    this.quantity = 10,
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

  final _licensePlateController = TextEditingController();
  final _capacityController = TextEditingController();
  final _modelController = TextEditingController();
  final _locFromController = TextEditingController();
  final _locToController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.depotLatitude != null && widget.depotLongitude != null) {
      _getDepotAddress();
    }
  }

  Future<void> _getDepotAddress() async {
    try {
      print(
        '📍 Depot koordinatları: ${widget.depotLatitude}, ${widget.depotLongitude}',
      );
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${widget.depotLatitude}&lon=${widget.depotLongitude}&accept-language=tr',
        ),
        headers: {'User-Agent': 'TarladanApp/1.0 (Flutter)'},
      );

      print('📍 Geocoding response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fullAddress = data['display_name'] ?? 'Depo konumu';

        // Adresi il / ilçe formatına çevir
        String shortAddress = fullAddress;
        final parts = fullAddress.split(',').map((e) => e.trim()).toList();
        if (parts.length >= 4) {
          // İl (parts[parts.length - 3]) ve İlçe (parts[parts.length - 4])
          shortAddress =
              '${parts[parts.length - 3]} / ${parts[parts.length - 4]}';
        } else if (parts.length == 3) {
          shortAddress = '${parts[1]} / ${parts[0]}';
        } else if (parts.length == 2) {
          shortAddress = '${parts[1]} / ${parts[0]}';
        }

        if (mounted) {
          setState(() {
            _locFromController.text = shortAddress;
          });
          print('✅ Depo adresi: $shortAddress');
        }
      } else {
        print('❌ Geocoding error: ${response.body}');
        if (mounted) {
          setState(() {
            _locFromController.text = 'Depo konumu alınamadı';
          });
        }
      }
    } catch (e) {
      print('❌ Depo adresi alınamadı: $e');
      if (mounted) {
        setState(() {
          _locFromController.text = 'Depo konumu alınamadı';
        });
      }
    }
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _capacityController.dispose();
    _modelController.dispose();
    _locFromController.dispose();
    _locToController.dispose();
    super.dispose();
  }

  Future<void> _handleBuyAndPay() async {
    // Validation
    if (_locFromController.text.isEmpty || _locToController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen nereden ve nereye bilgilerini girin'),
        ),
      );
      return;
    }

    if (_selectedLogistic == 'no_truck' && _selectedTruckId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir tır seçin')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final orderData = {
        'productId': widget.productId,
        'depotId': widget.depotId,
        'truckId': _selectedTruckId ?? 1,
        'locFrom': _locFromController.text,
        'locTo': _locToController.text,
        'quantityKg': widget.quantity,
      };

      print('📦 Order Data: $orderData');

      final authHeaders = await TokenService.getAuthHeaders();
      authHeaders['Content-Type'] = 'application/json';

      final response = await http.post(
        Uri.parse(ApiConfig.createOrderUrl),
        headers: authHeaders,
        body: jsonEncode(orderData),
      );

      print('📦 Order Response: ${response.statusCode}');
      print('📦 Order Response Body: ${response.body}');

      await TokenService.checkAndUpdateToken(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sipariş başarıyla oluşturuldu!'),
              backgroundColor: Color(0xFF4CAF50),
              duration: Duration(seconds: 1),
            ),
          );

          // Hemen geri dön
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        throw Exception('Sipariş oluşturulamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Order Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.price * widget.quantity;

    return ThemedScaffold(
      appBar: ThemedAppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Satın Alma',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      final selectedTruckData = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomerSelectTruckPage(),
                        ),
                      );

                      if (selectedTruckData != null && mounted) {
                        setState(() {
                          _selectedTruckId = selectedTruckData['truckId'];
                          _selectedTruckerName =
                              selectedTruckData['truckerName'];
                          _selectedTruckVehicle = selectedTruckData['vehicle'];
                          _selectedTruckPlate = selectedTruckData['plate'];
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tır seçildi: $_selectedTruckerName'),
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
                    child: Text(
                      _selectedTruckId == null
                          ? 'Tır Listesine Git'
                          : '$_selectedTruckerName - $_selectedTruckVehicle ($_selectedTruckPlate)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Location Fields
              _buildTextField(
                controller: _locFromController,
                label: 'Nereden',
                hint: 'Depo konumu yükleniyor...',
                readOnly: true,
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _locToController,
                    label: 'Nereye',
                    hint: 'Örn: İzmir / Bornova',
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const _MapSelectionPage(),
                          ),
                        );
                        if (result != null && mounted) {
                          setState(() {
                            _locToController.text = result;
                          });
                        }
                      },
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Haritadan Seç'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4CAF50),
                        side: const BorderSide(color: Color(0xFF4CAF50)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
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
                  onPressed: _isLoading ? null : _handleBuyAndPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Satın Al ve Öde',
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
    bool readOnly = false,
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
          readOnly: readOnly,
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

class _MapSelectionPage extends StatefulWidget {
  const _MapSelectionPage();

  @override
  State<_MapSelectionPage> createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<_MapSelectionPage> {
  LatLng? _selectedLocation;
  String? _selectedAddress;
  bool _isLoadingAddress = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Varsayılan konum: Türkiye merkezi
        setState(() {
          _selectedLocation = const LatLng(39.0, 35.0);
        });
        _getAddressFromLatLng(const LatLng(39.0, 35.0));
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = location;
      });
      _getAddressFromLatLng(location);
    } catch (e) {
      // Hata durumunda varsayılan konum
      const defaultLocation = LatLng(39.0, 35.0);
      setState(() {
        _selectedLocation = defaultLocation;
      });
      _getAddressFromLatLng(defaultLocation);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&accept-language=tr',
        ),
        headers: {'User-Agent': 'TarladanApp/1.0 (Flutter)'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _selectedAddress = data['display_name'] ?? 'Seçili konum';
            _isLoadingAddress = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _selectedAddress = 'Seçili konum';
            _isLoadingAddress = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedAddress = 'Seçili konum';
          _isLoadingAddress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konum Seç'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _selectedLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation!,
                    initialZoom: 13.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedLocation = point;
                      });
                      _getAddressFromLatLng(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.gangofthree.tarladan',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Confirm button
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isLoadingAddress)
                          const CircularProgressIndicator(
                            color: Color(0xFF4CAF50),
                          )
                        else if (_selectedAddress != null)
                          Text(
                            _selectedAddress!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_selectedAddress != null) {
                                Navigator.pop(context, _selectedAddress);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Konumu Onayla',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
