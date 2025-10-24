# Kayıt Ol Butonu Entegrasyon Değişiklikleri

## 📋 Genel Bakış
Backend'deki `/api/users/register` endpoint'i ile frontend'deki "Kayıt Ol" butonunun entegrasyonu yapıldı. Kullanıcı kayıt olduktan sonra e-posta doğrulama ekranına yönlendiriliyor.

---

## 🔧 Backend Değişiklikleri

### 1. CORS (Cross-Origin Resource Sharing) Desteği Eklendi

**Dosya:** `/backend/src/main/java/com/gangofthree/tarladan/core/config/CorsConfig.java` (YENİ)

**Açıklama:**
- Web tarayıcılarından gelen isteklere izin vermek için CORS yapılandırması eklendi
- Development ortamı için tüm localhost portlarına izin verildi

**Özellikler:**
- `AllowedOriginPatterns`: `http://localhost:*` ve `http://127.0.0.1:*`
- `AllowedMethods`: GET, POST, PUT, DELETE, OPTIONS, PATCH
- `AllowedHeaders`: Tüm header'lara izin
- `AllowCredentials`: true (Cookie ve authentication için)
- `MaxAge`: 3600 saniye (1 saat)

```java
@Configuration
public class CorsConfig {
    @Bean
    public CorsFilter corsFilter() {
        // Development için tüm localhost origin'lerine izin ver
        config.setAllowedOriginPatterns(Arrays.asList(
            "http://localhost:*",
            "http://127.0.0.1:*"
        ));
        // ... diğer ayarlar
    }
}
```

### 2. SecurityConfig'e CORS Desteği Eklendi

**Dosya:** `/backend/src/main/java/com/gangofthree/tarladan/core/security/SecurityConfig.java`

**Değişiklik:**
```java
http
    .csrf(AbstractHttpConfigurer::disable)
    .cors(cors -> cors.configure(http)) // ← YENİ EKLENEN
    .formLogin(AbstractHttpConfigurer::disable)
    .httpBasic(AbstractHttpConfigurer::disable)
```

**Açıklama:**
- Spring Security'nin CORS desteği aktif edildi
- Web uygulamalarından gelen istekler artık kabul ediliyor

---

## 🎨 Frontend Değişiklikleri

### 1. HTTP Paketi Eklendi

**Dosya:** `/frontend/pubspec.yaml`

**Değişiklik:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.1.0  # ← YENİ EKLENEN
```

**Açıklama:**
- Backend ile HTTP iletişimi için `http` paketi eklendi
- `flutter pub get` komutuyla yüklendi

### 2. API Konfigürasyon Dosyası Oluşturuldu

**Dosya:** `/frontend/lib/config/api_config.dart` (YENİ)

**Özellikler:**
- Platform bazlı URL yönetimi
- Endpoint sabitleri
- Merkezi API yapılandırması

```dart
class ApiConfig {
  static String get baseUrl {
    // Web platform
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    
    // Android emulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';  // Android emulator özel IP
    }
    
    // iOS/macOS
    if (Platform.isIOS || Platform.isMacOS) {
      return 'http://localhost:8080';
    }
    
    return 'http://localhost:8080';
  }
  
  static const String registerEndpoint = '/api/users/register';
  static String get registerUrl => '$baseUrl$registerEndpoint';
}
```

### 3. E-posta Doğrulama Ekranı Oluşturuldu

**Dosya:** `/frontend/lib/screens/verification_screen.dart` (YENİ)

**Özellikler:**
- E-posta doğrulama kodu girişi
- 6 haneli kod input alanı
- "Kodu tekrar gönder" butonu
- Kullanıcının e-posta adresini gösterir

**Ekran Yapısı:**
```dart
VerificationScreen({required String email})
- E-posta doğrulama başlığı
- Açıklama metni (e-posta adresini gösterir)
- 6 haneli kod input alanı
- "Doğrula" butonu
- "Kodu tekrar gönder" butonu
```

### 4. Kayıt Ekranı (signup_screen.dart) Güncellemeleri

#### 4.1. Form Controller'ları Eklendi

**Eklenen Controller'lar:**
```dart
final TextEditingController _nameController = TextEditingController();
final TextEditingController _surnameController = TextEditingController();
final TextEditingController _phoneController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
```

**Açıklama:**
- Her input alanı için controller eklendi
- Kullanıcı girişlerini yakalamak için kullanılıyor
- dispose() metodunda temizleniyor (memory leak önleme)

#### 4.2. Form Validasyonu Eklendi

**Ad ve Soyad:**
- Boş olamaz kontrolü
- Hata mesajı: "Lütfen adınızı/soyadınızı girin"

**Telefon Numarası:**
```dart
TextFormField(
  controller: _phoneController,
  decoration: const InputDecoration(
    labelText: 'Telefon',
    prefixText: '0',           // Sabit 0 prefix
    hintText: '5XX XXX XX XX', // Format örneği
  ),
  maxLength: 10,
  validator: (value) {
    // Boş kontrol
    if (value == null || value.isEmpty) {
      return 'Lütfen telefon numaranızı girin';
    }
    // Sadece rakam kontrolü
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Sadece rakam giriniz';
    }
    // 10 hane kontrolü
    if (value.length != 10) {
      return 'Telefon numarası 10 haneli olmalıdır';
    }
    // 5 ile başlamalı
    if (!value.startsWith('5')) {
      return 'Telefon numarası 5 ile başlamalıdır';
    }
    return null;
  },
)
```

**E-posta:**
- Boş olamaz kontrolü
- @ işareti kontrolü
- Hata mesajları:
  - "Lütfen e-posta adresinizi girin"
  - "Geçerli bir e-posta adresi girin"

**Parola:**
- Boş olamaz kontrolü
- Minimum 6 karakter kontrolü
- Hata mesajları:
  - "Lütfen parola girin"
  - "Parola en az 6 karakter olmalıdır"

#### 4.3. Rol Mapping Eklendi

**Önceki Durum:**
```dart
final roles = [
  {'label': 'Çiftçi', 'icon': Icons.spa},
  {'label': 'Alıcı', 'icon': Icons.shopping_cart},
  // ...
];
```

**Yeni Durum:**
```dart
final roles = [
  {'label': 'Çiftçi', 'icon': Icons.spa, 'value': 'FARMER'},
  {'label': 'Alıcı', 'icon': Icons.shopping_cart, 'value': 'BUYER'},
  {'label': 'Tırcı', 'icon': Icons.local_shipping, 'value': 'DRIVER'},
  {'label': 'Depocu', 'icon': Icons.apartment, 'value': 'DEPOT_OWNER'},
];
```

**Açıklama:**
- Türkçe etiketler kullanıcıya gösteriliyor
- Backend'e İngilizce enum değerleri gönderiliyor
- `_getRoleValue()` fonksiyonu ile mapping yapılıyor

#### 4.4. Rol Seçimi Görsel Uyarı Sistemi

**Eklenen Özellikler:**

1. **State Variable:**
```dart
bool _showRoleError = false;
```

2. **Görsel Uyarı Mesajı:**
```dart
if (_showRoleError)
  Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.red[700], size: 18),
        const SizedBox(width: 6),
        Text(
          "Lütfen bir rol seçin",
          style: TextStyle(color: Colors.red[700], fontSize: 13),
        ),
      ],
    ),
  ),
```

3. **Kırmızı Çerçeve:**
```dart
Container(
  decoration: BoxDecoration(
    border: Border.all(
      color: _showRoleError ? Colors.red : Colors.transparent,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  // Rol kartları...
)
```

4. **Dinamik Davranış:**
- Kayıt Ol'a basıldığında rol seçilmediyse → Hata göster
- Rol seçildiğinde → Hata otomatik kaldır

#### 4.5. API Entegrasyonu (_register Fonksiyonu)

**Fonksiyon Akışı:**

```dart
Future<void> _register() async {
  // 1. Form validasyonu
  if (!_formKey.currentState!.validate()) {
    return;
  }

  // 2. Rol seçimi kontrolü
  if (selectedRole == null) {
    setState(() {
      _showRoleError = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Lütfen bir rol seçin"),
        backgroundColor: Colors.red,
      )
    );
    return;
  }

  // 3. Loading state başlat
  setState(() {
    _isLoading = true;
    _showRoleError = false;
  });

  try {
    // 4. Telefon numarasını hazırla (0 prefix ekle)
    final fullPhoneNumber = '0${_phoneController.text.trim()}';

    // 5. Debug logları
    print('API URL: ${ApiConfig.registerUrl}');
    print('Gönderilen veri: {...}');

    // 6. Backend'e POST isteği
    final response = await http.post(
      Uri.parse(ApiConfig.registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': fullPhoneNumber,
        'password': _passwordController.text,
        'role': _getRoleValue(selectedRole!),
      }),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Bağlantı zaman aşımına uğradı.');
      },
    );

    // 7. Response kontrolü
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Başarılı kayıt
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kayıt başarılı! E-postanızı kontrol edin."),
          backgroundColor: Colors.green,
        ),
      );
      
      // Doğrulama ekranına yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            email: _emailController.text.trim(),
          ),
        ),
      );
    } else {
      // Hata durumu
      final errorMessage = response.body.isNotEmpty
          ? jsonDecode(response.body)['message'] ?? 'Kayıt başarısız oldu'
          : 'Kayıt başarısız oldu';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    // 8. Exception handling
    String errorMessage = 'Bağlantı hatası: ';
    
    if (e.toString().contains('Failed host lookup')) {
      errorMessage += 'Sunucuya ulaşılamadı.';
    } else if (e.toString().contains('Connection refused')) {
      errorMessage += 'Bağlantı reddedildi.';
    } else if (e.toString().contains('SocketException')) {
      errorMessage += 'Ağ bağlantısı hatası.';
    } else if (e.toString().contains('timeout')) {
      errorMessage += 'İstek zaman aşımına uğradı.';
    } else {
      errorMessage += e.toString();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  } finally {
    // 9. Loading state kapat
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
```

#### 4.6. Kayıt Ol Butonu Güncellendi

**Önceki Durum:**
```dart
ElevatedButton(
  onPressed: () {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen bir rol seçin")),
      );
    } else {
      // Kayıt işlemleri
    }
  },
  child: const Text("Kayıt Ol"),
)
```

**Yeni Durum:**
```dart
ElevatedButton(
  onPressed: _isLoading ? null : _register,  // Loading sırasında devre dışı
  child: _isLoading
      ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
      : const Text(
          "Kayıt Ol",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
)
```

**Özellikler:**
- Loading sırasında buton devre dışı
- Loading indicator gösteriliyor
- API isteği tamamlanana kadar çift tıklama engelleniyor

### 5. macOS Ağ İzinleri Eklendi

**Dosyalar:**
- `/frontend/macos/Runner/DebugProfile.entitlements`
- `/frontend/macos/Runner/Release.entitlements`

**Eklenen İzin:**
```xml
<key>com.apple.security.network.client</key>
<true/>
```

**Açıklama:**
- macOS sandbox'ı dış ağ bağlantılarını engeller
- Bu izin olmadan localhost'a bile istek atılamaz
- Debug ve Release modları için eklendi

---

## 📊 Veri Akışı

### Kullanıcı Girişi → Backend İsteği

**Kullanıcı Girdisi:**
```
Ad: Koray
Soyad: Urun
Telefon: 5050489839 (0 otomatik ekleniyor)
E-posta: korayurun07@gmail.com
Parola: 1234567
Rol: Çiftçi (seçim)
```

**Backend'e Gönderilen JSON:**
```json
{
  "name": "Koray",
  "surname": "Urun",
  "email": "korayurun07@gmail.com",
  "phone": "05050489839",
  "password": "1234567",
  "role": "FARMER"
}
```

**Backend Response (Başarılı):**
```json
{
  "id": 1,
  "name": "Koray",
  "surname": "Urun",
  "phone": "05050489839",
  "email": "korayurun07@gmail.com",
  "role": "FARMER",
  "mailVerified": false,
  "googleVerified": false,
  "phoneVerified": false
}
```

### Ekran Akışı

```
SignupScreen (Kayıt Formu)
    ↓
[Kullanıcı formu doldurur]
    ↓
[Kayıt Ol butonuna tıklar]
    ↓
[Validasyon kontrolleri]
    ↓
[Backend'e POST isteği]
    ↓
[Başarılı ise]
    ↓
VerificationScreen (E-posta Doğrulama)
```

---

## 🔒 Güvenlik Önlemleri

### Frontend
1. **Form Validasyonu**: Tüm alanlar doğrulanıyor
2. **Timeout**: 10 saniye timeout ile sonsuz bekleme engelleniyor
3. **Error Handling**: Tüm hatalar yakalanıp kullanıcıya gösteriliyor
4. **Loading State**: Çift tıklama ve tekrarlı istekler engelleniyor

### Backend
1. **CORS**: Sadece localhost origin'lerine izin (development için)
2. **Content-Type**: application/json zorunluluğu
3. **Password Encryption**: BCrypt ile şifreleme (backend tarafında)
4. **Validation**: Backend'de ek validasyon katmanı

---

## 🧪 Test Senaryoları

### ✅ Başarılı Kayıt
1. Tüm alanları doldur
2. Geçerli e-posta formatı gir
3. 10 haneli telefon numarası gir (5 ile başlayan)
4. En az 6 karakterli parola gir
5. Rol seç
6. Kayıt Ol'a tıkla
7. Backend'e istek gönderilir
8. Başarılı mesaj gösterilir
9. Verification ekranına yönlendirilir

### ❌ Hata Senaryoları

**Boş Alanlar:**
- Mesaj: "Lütfen {alan_adı} girin"

**Geçersiz E-posta:**
- Mesaj: "Geçerli bir e-posta adresi girin"

**Kısa Parola:**
- Mesaj: "Parola en az 6 karakter olmalıdır"

**Geçersiz Telefon:**
- 10 haneden az: "Telefon numarası 10 haneli olmalıdır"
- 5 ile başlamıyor: "Telefon numarası 5 ile başlamalıdır"
- Harf içeriyor: "Sadece rakam giriniz"

**Rol Seçilmedi:**
- Kırmızı uyarı mesajı gösterilir
- Rol kartlarının etrafı kırmızı olur
- SnackBar: "Lütfen bir rol seçin"

**Backend Hataları:**
- Connection refused: "Bağlantı reddedildi"
- Timeout: "İstek zaman aşımına uğradı"
- Network error: "Ağ bağlantısı hatası"

---

## 🎯 Sonuç

### Tamamlanan Özellikler
✅ Backend CORS konfigürasyonu
✅ API konfigürasyon dosyası (platform bazlı)
✅ Form validasyonu (tüm alanlar)
✅ Telefon numarası formatı (0 prefix + 10 hane)
✅ Rol seçimi görsel uyarı sistemi
✅ API entegrasyonu (register endpoint)
✅ Loading state ve hata yönetimi
✅ E-posta doğrulama ekranı
✅ macOS ağ izinleri
✅ Timeout ve error handling
✅ Debug logları

### Bekleyen İşler (TODO)
- [ ] Verification ekranında kod doğrulama API entegrasyonu
- [ ] "Kodu tekrar gönder" özelliği
- [ ] Production ortamı için CORS yapılandırması (spesifik domain'ler)
- [ ] Backend error response'larının standartlaştırılması
- [ ] Loading animasyonlarının iyileştirilmesi
- [ ] Parola güvenlik seviyesi göstergesi (opsiyonel)

---

## 📝 Notlar

### Platform Özel Bilgiler

**Web:**
- CORS desteği gerekli
- `http://localhost:8080` kullanılıyor

**Android Emulator:**
- `http://10.0.2.2:8080` kullanılmalı
- `localhost` emulator'ün kendi localhost'una işaret eder

**iOS Simulator:**
- `http://localhost:8080` çalışır
- Gerçek cihazda bilgisayarın IP adresi gerekli

**macOS:**
- Ağ izinleri (entitlements) şart
- Sandbox kısıtlamaları var

### Debug İpuçları

**Console Logları:**
```
API URL: http://localhost:8080/api/users/register
Gönderilen veri: {"name":"...","surname":"...",...}
Response status: 200
Response body: {...}
```

**CORS Test:**
```bash
curl -X OPTIONS http://localhost:8080/api/users/register \
  -H "Origin: http://localhost:8081" \
  -H "Access-Control-Request-Method: POST" -v
```

**API Test:**
```bash
curl -X POST http://localhost:8080/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","surname":"User","email":"test@example.com","phone":"05555555555","password":"123456","role":"FARMER"}'
```

---

**Oluşturulma Tarihi:** 24 Ekim 2025
**Versiyon:** 1.0
**Branch:** integration/register
