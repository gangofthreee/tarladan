import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'token_service.dart';
import 'google_auth_service.dart';

/// Auth Service - Login işlemlerini yönetir
class AuthService {
  static final _googleAuthService = GoogleAuthService();

  /// Email/password ile giriş yap
  static Future<AuthResult> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await TokenService.saveAccessToken(data['accessToken'] ?? '');
        await TokenService.saveRefreshToken(data['refreshToken'] ?? '');
        await TokenService.saveUserRole(data['role'] ?? '');
        return AuthResult.success(data['role']);
      }
      return AuthResult.error('Giriş başarısız. Lütfen bilgilerinizi kontrol edin.');
    } catch (e) {
      return AuthResult.error('Bir hata oluştu: $e');
    }
  }

  /// Google ile giriş yap
  static Future<GoogleAuthResult> googleSignIn() async {
    try {
      final idToken = await _googleAuthService.signIn();
      if (idToken == null) return GoogleAuthResult.cancelled();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/google/verify-status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['isRegistered'] == true || data['registered'] == true) {
          final tokenResponse = data['tokenResponse'];
          await TokenService.saveAccessToken(tokenResponse['accessToken']);
          await TokenService.saveRefreshToken(tokenResponse['refreshToken']);
          await TokenService.saveUserRole(tokenResponse['role'] ?? '');
          await Future.delayed(const Duration(milliseconds: 500));
          return GoogleAuthResult.success(tokenResponse['role']);
        }
        return GoogleAuthResult.needsRegistration(idToken);
      }
      return GoogleAuthResult.error('Google ile giriş başarısız.');
    } catch (e) {
      return GoogleAuthResult.error('Google giriş hatası: $e');
    }
  }

  /// Login durumunu kontrol et
  static Future<AuthResult> checkLoginStatus() async {
    final token = await TokenService.getAccessToken();
    final role = await TokenService.getUserRole();

    if (token != null && token.isNotEmpty && role != null && role.isNotEmpty) {
      return AuthResult.success(role);
    }
    return AuthResult.error('Not logged in');
  }
}

/// Auth sonuç sınıfı
class AuthResult {
  final bool isSuccess;
  final String? role;
  final String? error;

  AuthResult._(this.isSuccess, this.role, this.error);

  factory AuthResult.success(String role) => AuthResult._(true, role, null);
  factory AuthResult.error(String message) => AuthResult._(false, null, message);
}

/// Google Auth sonuç sınıfı
class GoogleAuthResult {
  final bool isSuccess;
  final bool isCancelled;
  final bool needsRegistration;
  final String? role;
  final String? idToken;
  final String? error;

  GoogleAuthResult._(this.isSuccess, this.isCancelled, this.needsRegistration, this.role, this.idToken, this.error);

  factory GoogleAuthResult.success(String role) => GoogleAuthResult._(true, false, false, role, null, null);
  factory GoogleAuthResult.cancelled() => GoogleAuthResult._(false, true, false, null, null, null);
  factory GoogleAuthResult.needsRegistration(String idToken) => GoogleAuthResult._(false, false, true, null, idToken, null);
  factory GoogleAuthResult.error(String message) => GoogleAuthResult._(false, false, false, null, null, message);
}
