/// Google OAuth Configuration
/// 
/// Bu dosya Google Sign-In için gerekli Client ID'leri içerir.
/// Her platform için ayrı Client ID kullanılır.
class GoogleAuthConfig {
  // Web Client ID (Backend doğrulama için de kullanılır)
  static const String webClientId = 
      '1016917742802-ihtesukfb5d0jj0181eu54vqtamo3bjb.apps.googleusercontent.com';
  
  // Web Client Secret (Sadece backend tarafında kullanılmalı)
  static const String webClientSecret = 'GOCSPX-NgtUYpTN5psk7jyMpqdsX4uXoJB';
  
  // Android Client ID
  static const String androidClientId = 
      '1016917742802-33tv8u1e6lle8357gr68s8l1i34bevvo.apps.googleusercontent.com';
  
  // iOS Client ID
  static const String iosClientId = 
      '1016917742802-euehhgipssqflir6e8f6vhlqqfrfebqf.apps.googleusercontent.com';
  
  // Reversed iOS Client ID (URL Scheme için)
  static const String iosReversedClientId = 
      'com.googleusercontent.apps.1016917742802-euehhgipssqflir6e8f6vhlqqfrfebqf';
  
  /// Platform bazlı Client ID döndürür
  static String getClientId() {
    // Platform kontrolü için dart:io kullanılabilir
    // Şimdilik web client ID döndürüyoruz
    return webClientId;
  }
}
