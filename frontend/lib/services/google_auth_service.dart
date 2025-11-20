import 'package:google_sign_in/google_sign_in.dart';
import '../config/google_auth_config.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Google Sign-In servisi
/// iOS, Android ve Web platformlarında Google OAuth entegrasyonu sağlar
class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  GoogleSignIn? _googleSignIn;

  /// GoogleSignIn instance'ını döndürür, gerekirse oluşturur
  GoogleSignIn get googleSignIn {
    if (_googleSignIn != null) {
      return _googleSignIn!;
    }

    // Platform bazlı client ID seçimi
    String clientId;
    
    if (kIsWeb) {
      clientId = GoogleAuthConfig.webClientId;
    } else if (Platform.isIOS) {
      clientId = GoogleAuthConfig.iosClientId;
    } else if (Platform.isAndroid) {
      clientId = GoogleAuthConfig.androidClientId;
    } else {
      clientId = GoogleAuthConfig.webClientId; // Fallback
    }

    _googleSignIn = GoogleSignIn(
      clientId: clientId,
      scopes: [
        'email',
        'profile',
      ],
    );

    return _googleSignIn!;
  }

  /// Google ile giriş yapar ve ID token döner
  /// 
  /// Returns: ID Token (String) veya null (kullanıcı iptal ederse)
  /// Throws: Exception (hata durumunda)
  Future<String?> signIn() async {
    try {
      // Önceki oturumu temizle
      await googleSignIn.signOut();
      
      // Google Sign-In akışını başlat
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      
      if (account == null) {
        // Kullanıcı giriş işlemini iptal etti
        return null;
      }

      // Authentication bilgilerini al
      final GoogleSignInAuthentication auth = await account.authentication;
      
      // ID Token'ı döndür
      return auth.idToken;
    } catch (error) {
      throw Exception('Google Sign-In hatası: $error');
    }
  }

  /// Kullanıcının Google hesabından çıkış yapar
  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
    } catch (error) {
      throw Exception('Google Sign-Out hatası: $error');
    }
  }

  /// Kullanıcının şu anda giriş yapıp yapmadığını kontrol eder
  Future<bool> isSignedIn() async {
    return await googleSignIn.isSignedIn();
  }

  /// Şu anki kullanıcı bilgilerini döner
  GoogleSignInAccount? get currentUser => googleSignIn.currentUser;
}
