import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TokenService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Access token kaydet
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  // Refresh token kaydet
  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  // Access token al
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Refresh token al
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Token'ları temizle (logout)
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // Response'dan yeni token'ı kontrol et ve kaydet
  static Future<void> checkAndUpdateToken(http.Response response) async {
    // Backend X-New-Access-Token olarak gönderiyor (case-insensitive)
    final newToken =
        response.headers['x-new-access-token'] ??
        response.headers['X-New-Access-Token'];
    if (newToken != null && newToken.isNotEmpty) {
      await saveAccessToken(newToken);
      print('✅ New access token received and saved');
    }
  }

  // Authorization header oluştur
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();
    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  // Multipart için Authorization header
  static Future<Map<String, String>> getAuthHeadersForMultipart() async {
    final token = await getAccessToken();
    if (token != null) {
      return {'Authorization': 'Bearer $token'};
    }
    return {};
  }
}
