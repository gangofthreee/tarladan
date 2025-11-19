/// Backend session-based authentication kullandığı için cookie'leri saklamak gerekiyor.
///
/// Flow:
/// 1. /auth/password-reset/confirm-code endpoint'i kodu doğruladıktan sonra
///    response header'ında JSESSIONID cookie'si gönderir (Spring Boot default)
/// 2. Bu cookie'yi saklıyoruz
/// 3. /auth/password-reset/set-password isteğinde bu cookie'yi gönderiyoruz
/// 4. Backend session'dan verified-reset-code'u alıp şifre güncellemeyi yapıyor
///
/// Not: http paketi otomatik cookie yönetimi yapmadığı için manuel olarak
/// set-cookie header'ını okuyup, sonraki isteklerde Cookie header'ına ekliyoruz.
class SessionService {
  static String? _sessionCookie;

  /// Backend'den gelen set-cookie header'ını kaydet
  static void saveSessionCookie(String? cookie) {
    if (cookie != null) {
      // set-cookie header'ı "JSESSIONID=xxx; Path=/; HttpOnly" formatında gelir
      // Sadece JSESSIONID=xxx kısmını al
      final jsessionId = cookie.split(';').first;
      _sessionCookie = jsessionId;
    }
  }

  static String? getSessionCookie() {
    return _sessionCookie;
  }

  /// Şifre sıfırlama flow'u bittiğinde session'ı temizle
  static void clearSession() {
    _sessionCookie = null;
  }

  /// API istekleri için cookie içeren header'lar oluştur
  static Map<String, String> getHeadersWithSession() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_sessionCookie != null) {
      headers['Cookie'] = _sessionCookie!;
    }
    return headers;
  }
}
