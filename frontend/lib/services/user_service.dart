import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_service.dart';

class UserService {
  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final token = await TokenService.getAccessToken();

      if (token == null) {
        print('Token bulunamadı');
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('User Info Response Status: ${response.statusCode}');
      print('User Info Response Body: ${response.body}');

      // Backend'den yeni token gelmiş mi kontrol et
      await TokenService.checkAndUpdateToken(response);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Kullanıcı bilgisi alınamadı: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Kullanıcı bilgisi alma hatası: $e');
      return null;
    }
  }

  static Future<String> getUserFullName() async {
    final userInfo = await getUserInfo();
    if (userInfo != null) {
      final name = userInfo['name'] ?? '';
      final surname = userInfo['surname'] ?? '';
      return '$name $surname'.trim();
    }
    return 'Kullanıcı';
  }

  static Future<String> getUserFirstName() async {
    try {
      final userInfo = await getUserInfo();
      if (userInfo != null) {
        final name = userInfo['name'];
        print('Kullanıcı adı alındı: $name');
        return name ?? 'Kullanıcı';
      }
      print('UserInfo null döndü');
      return 'Kullanıcı';
    } catch (e) {
      print('getUserFirstName hatası: $e');
      return 'Kullanıcı';
    }
  }
}
