import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import 'password_reset_verification_screen.dart';
import '../../widgets/user_base_screen.dart';
import '../../widgets/user_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SnackBarHelper {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendResetCode() async {
    if (_emailController.text.isEmpty) {
      showErrorSnackBar('Lütfen e-posta adresinizi girin');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      showErrorSnackBar('Geçerli bir e-posta adresi girin');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': _emailController.text.trim()}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PasswordResetVerificationScreen(email: _emailController.text.trim()),
          ),
        );
      } else {
        showErrorSnackBar('Kod gönderilemedi. Lütfen e-posta adresinizi kontrol edin.');
      }
    } catch (e) {
      showErrorSnackBar('Bağlantı hatası: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UserBaseScreen(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Şifremi Unuttum',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
              const SizedBox(height: 16),
              Text(
                'Şifre sıfırlama kodu almak için e-posta adresinizi girin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.primaryGreen, fontSize: 16),
                decoration: AppInputDecoration.standard(label: 'E-posta Adresi'),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Şifre Sıfırlama Kodu Gönder',
                onPressed: _isLoading ? null : _sendResetCode,
                isLoading: _isLoading,
                borderRadius: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
