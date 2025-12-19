import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'token_service.dart';

class FarmerOrderService {
  static Future<(List<dynamic>?, String?)> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getFarmerOrdersUrl),
        headers: await TokenService.getAuthHeaders(),
      );
      await TokenService.checkAndUpdateToken(response);
      
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return (data is List ? data : [], null);
      }
      return (null, 'Hata: ${response.statusCode}');
    } catch (e) {
      return (null, 'Hata: $e');
    }
  }
}
