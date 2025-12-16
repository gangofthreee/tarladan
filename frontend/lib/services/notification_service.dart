import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'token_service.dart';

class NotificationService {
  // Bildirim sayacını getir (navbar badge için)
  static Future<int> getUnreadCount() async {
    try {
      final authHeaders = await TokenService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.getUnreadCountUrl),
        headers: authHeaders,
      );

      await TokenService.checkAndUpdateToken(response);

      if (response.statusCode == 200) {
        return int.parse(response.body);
      }
      return 0;
    } catch (e) {
      print('❌ Unread count hatası: $e');
      return 0;
    }
  }

  // Tüm bildirimleri getir
  static Future<List<Map<String, dynamic>>> getMyNotifications() async {
    try {
      final authHeaders = await TokenService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.getMyNotificationsUrl),
        headers: authHeaders,
      );

      await TokenService.checkAndUpdateToken(response);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('❌ Bildirimler yüklenemedi: $e');
      return [];
    }
  }

  // Bildirimi okundu işaretle
  static Future<bool> markAsRead(int notificationId) async {
    try {
      final authHeaders = await TokenService.getAuthHeaders();
      final response = await http.put(
        Uri.parse(ApiConfig.markAsReadUrl(notificationId)),
        headers: authHeaders,
      );

      await TokenService.checkAndUpdateToken(response);

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Okundu işaretleme hatası: $e');
      return false;
    }
  }
}
