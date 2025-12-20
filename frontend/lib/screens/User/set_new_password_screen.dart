import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../services/session_service.dart';
import 'login_screen.dart';
import '../../widgets/user_base_screen.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Şifre gereksinimleri
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

  bool _isPasswordValid() {
    return _hasMinLength && _hasUppercase && _hasNumber;
  }

  Future<void> _setNewPassword() async {
    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showError('Lütfen tüm alanları doldurun');
      return;
    }

    if (!_isPasswordValid()) {
      _showError('Şifre gereksinimlerini karşılamıyor');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Şifreler eşleşmiyor');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/password-reset/set-password'),
        headers: SessionService.getHeadersWithSession(),
        body: json.encode({'newPassword': _passwordController.text}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Session'ı temizle
        SessionService.clearSession();
        // Başarılı - login ekranına yönlendir
        _showSuccessAndNavigate();
      } else {
        _showError('Şifre güncellenemedi. Lütfen tekrar deneyin.');
      }
    } catch (e) {
      _showError('Bağlantı hatası: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessAndNavigate() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF7CB342).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF7CB342),
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Şifreniz Başarıyla Güncellendi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Yeni şifreniz ile giriş yapabilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7CB342),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Tüm sayfaları kapat ve login'e dön
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text(
                'Giriş Yap',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UserBaseScreen(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3A5A40)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Yeni Şifre Oluştur',
          style: TextStyle(
            color: Color(0xFF3A5A40),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Yeni bir şifre belirleyin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1117),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Güvenliğiniz için güçlü bir şifre oluşturun.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              // Yeni Şifre
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Color(0xFF3A5A40), fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF7CB342)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF7CB342)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3A5A40), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Yeni Şifreyi Onayla
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                style: const TextStyle(color: Color(0xFF3A5A40), fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Yeni Şifreyi Onayla',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF7CB342)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF7CB342)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3A5A40), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Şifre gereksinimleri
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequirement('En az 8 karakter', _hasMinLength),
                    const SizedBox(height: 8),
                    _buildRequirement(
                      'Bir büyük harf (A-Z)',
                      _hasUppercase,
                    ),
                    const SizedBox(height: 8),
                    _buildRequirement('Bir sayı (0-9)', _hasNumber),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Şifreyi Kaydet butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7CB342),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: _isLoading ? null : _setNewPassword,
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
                          'Şifreyi Kaydet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isMet ? const Color(0xFF7CB342) : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isMet ? Colors.black : Colors.grey[600],
            fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
