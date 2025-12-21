import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../services/session_service.dart';
import 'login_screen.dart';
import '../../widgets/user_base_screen.dart';
import '../../widgets/user_widgets.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});
  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> with SnackBarHelper {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false, _obscure1 = true, _obscure2 = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
  }

  bool get _isValid {
    final p = _passwordController.text;
    return p.length >= 8 && RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[0-9]').hasMatch(p);
  }

  Future<void> _submit() async {
    if (_passwordController.text.isEmpty || _confirmController.text.isEmpty) {
      return showErrorSnackBar('Lütfen tüm alanları doldurun');
    }
    if (!_isValid) return showErrorSnackBar('Şifre gereksinimlerini karşılamıyor');
    if (_passwordController.text != _confirmController.text) return showErrorSnackBar('Şifreler eşleşmiyor');

    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/password-reset/set-password'),
        headers: SessionService.getHeadersWithSession(),
        body: json.encode({'newPassword': _passwordController.text}),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        SessionService.clearSession();
        showSuccessDialog(context,
          title: 'Şifreniz Başarıyla Güncellendi',
          message: 'Yeni şifreniz ile giriş yapabilirsiniz.',
          buttonText: 'Giriş Yap',
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false),
        );
      } else {
        showErrorSnackBar('Şifre güncellenemedi.');
      }
    } catch (e) { showErrorSnackBar('Bağlantı hatası: $e'); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UserBaseScreen(
      appBar: UserAppBar(title: 'Yeni Şifre Oluştur', onBack: () => Navigator.pop(context)),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const Text('Yeni bir şifre belirleyin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkText)),
            const SizedBox(height: 12),
            Text('Güvenliğiniz için güçlü bir şifre oluşturun.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 32),
            PasswordTextField(controller: _passwordController, label: 'Yeni Şifre', isObscure: _obscure1, onToggle: () => setState(() => _obscure1 = !_obscure1)),
            const SizedBox(height: 16),
            PasswordTextField(controller: _confirmController, label: 'Yeni Şifreyi Onayla', isObscure: _obscure2, onToggle: () => setState(() => _obscure2 = !_obscure2)),
            const SizedBox(height: 24),
            PasswordRequirements(password: _passwordController.text),
            const SizedBox(height: 32),
            PrimaryButton(text: 'Şifreyi Kaydet', onPressed: _isLoading ? null : _submit, isLoading: _isLoading, borderRadius: 24),
          ]),
        ),
      ),
    );
  }
}
