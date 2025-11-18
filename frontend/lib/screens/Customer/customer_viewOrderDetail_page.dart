import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../services/token_service.dart';

import '../../widgets/themed_scaffold.dart';

class CustomerViewOrderDetailPage extends StatefulWidget {
  final int orderId;

  const CustomerViewOrderDetailPage({super.key, required this.orderId});

  @override
  State<CustomerViewOrderDetailPage> createState() =>
      _CustomerViewOrderDetailPageState();
}

class _CustomerViewOrderDetailPageState
    extends State<CustomerViewOrderDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _orderDetail;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authHeaders = await TokenService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.getOrderByIdUrl(widget.orderId)),
        headers: authHeaders,
      );

      await TokenService.checkAndUpdateToken(response);

      if (response.statusCode == 200) {
        setState(() {
          _orderDetail = jsonDecode(response.body) as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        throw Exception('Sipariş detayı yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Hata: $e';
      });
    }
  }

  void _handleCall() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Arama başlatılıyor...')));
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: ThemedAppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sipariş Detayı',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchOrderDetail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            )
          : _buildOrderDetailContent(),
    );
  }

  Widget _buildOrderDetailContent() {
    if (_orderDetail == null) return const SizedBox();

    final productName = _orderDetail!['productName'] ?? 'Ürün';
    final quantityKg = _orderDetail!['quantityKg'] ?? 0;
    final pricePerKg = _orderDetail!['pricePerKg'] ?? 0;
    final totalPrice = _orderDetail!['totalPrice'] ?? 0;
    final locFrom = _orderDetail!['locFrom'] ?? '';
    final locTo = _orderDetail!['locTo'] ?? '';
    final depotName = _orderDetail!['depotName'] ?? '';
    final truckPlate = _orderDetail!['truckPlate'] ?? '';
    final status = _orderDetail!['status'] ?? 'PENDING';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Sipariş Özeti
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text(
              'Sipariş Özeti',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Product Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  // Product Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 40,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${quantityKg}kg',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${totalPrice}₺',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Sipariş Detayları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sipariş Detayları',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow('Fiyat/kg', '${pricePerKg}₺'),
                  _buildDetailRow('Miktar', '${quantityKg}kg'),
                  _buildDetailRow(
                    'Toplam Tutar',
                    '${totalPrice}₺',
                    isHighlight: true,
                  ),
                  const Divider(height: 30),
                  _buildDetailRow('Nereden', locFrom),
                  _buildDetailRow('Nereye', locTo),
                  const Divider(height: 30),
                  _buildDetailRow('Depo', depotName),
                  _buildDetailRow('Araç Plakası', truckPlate),
                  const Divider(height: 30),
                  _buildDetailRow(
                    'Durum',
                    _getStatusText(status),
                    isStatus: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
    bool isStatus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight || isStatus ? 16 : 14,
              fontWeight: isHighlight || isStatus
                  ? FontWeight.bold
                  : FontWeight.w600,
              color: isHighlight
                  ? const Color(0xFF4CAF50)
                  : isStatus
                  ? _getStatusColor(value)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Beklemede';
      case 'COMPLETED':
        return 'Tamamlandı';
      case 'CANCELLED':
        return 'İptal Edildi';
      default:
        return status;
    }
  }

  Color _getStatusColor(String statusText) {
    if (statusText.contains('Beklemede')) {
      return const Color(0xFFFFA726);
    } else if (statusText.contains('Tamamlandı')) {
      return const Color(0xFF4CAF50);
    } else if (statusText.contains('İptal')) {
      return Colors.red;
    }
    return Colors.grey;
  }
}
