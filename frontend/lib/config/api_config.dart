import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Web platform kontrolü
    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    // Android emulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }

    // iOS simulator veya macOS
    if (Platform.isIOS || Platform.isMacOS) {
      return 'http://localhost:8080';
    }

    // Diğer platformlar (Windows, Linux)
    return 'http://localhost:8080';
  }

  static const String registerEndpoint = '/api/users/register';
  static const String verifyEndpoint = '/api/users/verify';
  static const String verifyCodeEndpoint = '/api/verification/verifyCode';
  static const String resendCodeEndpoint = '/api/verification/resendCode';
  static const String createProductEndpoint = '/farmer/product/create';

  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get verifyUrl => '$baseUrl$verifyEndpoint';
  static String get verifyCodeUrl => '$baseUrl$verifyCodeEndpoint';
  static String resendCodeUrl(String email) =>
      '$baseUrl$resendCodeEndpoint?email=$email';
  static String get createProductUrl => '$baseUrl$createProductEndpoint';
}
