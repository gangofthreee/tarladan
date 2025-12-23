import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TokenService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  // Android için encryptedSharedPreferences, iOS için accessibility ayarları
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Access token kaydet
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  // Refresh token kaydet
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  // Access token al
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Refresh token al
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static const String _userRoleKey = 'user_role';

  // Role kaydet
  static Future<void> saveUserRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role);
  }

  // Role al
  static Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }

  // Token'ları temizle (logout)
  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userRoleKey);
  }

  // Response'dan yeni token'ı kontrol et ve kaydet
  static Future<void> checkAndUpdateToken(http.Response response) async {
    // Backend X-New-Access-Token olarak gönderiyor (case-insensitive)
    final newToken =
        response.headers['x-new-access-token'] ??
        response.headers['X-New-Access-Token'];
    
    if (newToken != null && newToken.isNotEmpty) {
      await saveAccessToken(newToken);
      print('✅ Token yenilendi');
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
