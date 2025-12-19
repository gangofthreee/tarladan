import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'token_service.dart';

class CustomerOrderService {
  static Future<(bool, String?)> createOrder({
    required int productId,
    required int depotId,
    required int truckId,
    required String locFrom,
    required String locTo,
    required double quantityKg,
  }) async {
    try {
      final orderData = {
        'productId': productId,
        'depotId': depotId,
        'truckId': truckId,
        'locFrom': locFrom,
        'locTo': locTo,
        'quantityKg': quantityKg,
      };

      final authHeaders = await TokenService.getAuthHeaders();
      authHeaders['Content-Type'] = 'application/json';

      final response = await http.post(
        Uri.parse(ApiConfig.createOrderUrl),
        headers: authHeaders,
        body: jsonEncode(orderData),
      );

      await TokenService.checkAndUpdateToken(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return (true, null);
      }
      return (false, 'Sipariş oluşturulamadı (${response.statusCode})');
    } catch (e) {
      return (false, 'Hata: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final authHeaders = await TokenService.getAuthHeaders();
      final response = await http.get(Uri.parse(ApiConfig.getCustomerOrdersUrl), headers: authHeaders);
      
      await TokenService.checkAndUpdateToken(response);

      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = jsonDecode(response.body);
        final orders = ordersJson.map((order) => order as Map<String, dynamic>).toList();
        // Sort by id descending (newest first)
        orders.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
        return orders;
      } else {
        throw Exception('Siparişler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Siparişler alınırken hata: $e');
    }
  }

  static Future<Map<String, dynamic>> getOrderDetail(int orderId) async {
    try {
      final authHeaders = await TokenService.getAuthHeaders();
      final response = await http.get(Uri.parse(ApiConfig.getOrderByIdUrl(orderId)), headers: authHeaders);
      
      await TokenService.checkAndUpdateToken(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Sipariş detayı yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Sipariş detayı alınırken hata: $e');
    }
  }
}
