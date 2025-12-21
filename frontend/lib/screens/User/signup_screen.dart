import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'verification_screen.dart';
import '../../config/api_config.dart';
import '../../widgets/user_base_screen.dart';
import '../../widgets/user_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SnackBarHelper {
  final _formKey = GlobalKey<FormState>();
  String? _selectedRole;
  bool _showRoleError = false, _isLoading = false;

  final _name = TextEditingController();
  final _surname = TextEditingController();
  final _phone = TextEditingController(text: '0 5');
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose(); _surname.dispose(); _phone.dispose(); _email.dispose(); _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      setState(() => _showRoleError = true);
      return showErrorSnackBar("Lütfen bir rol seçin");
    }

    setState(() { _isLoading = true; _showRoleError = false; });

    try {
      final res = await http.post(
        Uri.parse(ApiConfig.registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _name.text.trim(),
          'surname': _surname.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.replaceAll(' ', '').trim(),
          'password': _password.text,
          'role': kRoles.firstWhere((r) => r['label'] == _selectedRole)['value'],
        }),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        showSuccessSnackBar("Kayıt başarılı!");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => VerificationScreen(email: _email.text.trim())));
      } else {
        _handleError(res);
      }
    } catch (e) {
      showErrorSnackBar(_parseError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleError(http.Response res) {
    var msg = 'Kayıt başarısız';
    try {
      final data = jsonDecode(res.body);
      if (data['error']?.toString().contains('Email already in use') == true) {
        msg = 'Bu e-posta zaten kullanılıyor.';
      } else {
        msg = data['error'] ?? data['message'] ?? msg;
      }
    } catch (_) {}
    showErrorSnackBar(msg);
  }

  String _parseError(String e) {
    if (e.contains('host lookup')) return 'Sunucuya ulaşılamıyor.';
    if (e.contains('refused')) return 'Bağlantı reddedildi.';
    if (e.contains('timeout')) return 'Zaman aşımı.';
    return 'Hata: $e';
  }

  @override
  Widget build(BuildContext context) {
    return UserBaseScreen(
      appBar: UserAppBar(title: "Hesap Oluştur", onBack: () => Navigator.pop(context)),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: [
            UnderlineTextField(controller: _name, label: 'Ad', validator: (v) => Validators.required(v, 'Lütfen adınızı girin')),
            const SizedBox(height: 12),
            UnderlineTextField(controller: _surname, label: 'Soyad', validator: (v) => Validators.required(v, 'Lütfen soyadınızı girin')),
            const SizedBox(height: 12),
            UnderlineTextField(
              controller: _phone, label: 'Telefon', hint: '0 5XX XXX XX XX', keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11), PhoneNumberFormatter()],
              validator: Validators.phone,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => Text('${_phone.text.replaceAll(' ', '').length}/11', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ),
            const SizedBox(height: 12),
            UnderlineTextField(controller: _email, label: 'E-posta', keyboardType: TextInputType.emailAddress, validator: Validators.email),
            const SizedBox(height: 12),
            UnderlineTextField(controller: _password, label: 'Şifre', obscureText: true, validator: Validators.password),
            const SizedBox(height: 8),
            PasswordRequirements(password: _password.text, showContainer: false),
            const SizedBox(height: 24),
            RoleSelectionGrid(
              selectedRole: _selectedRole,
              showError: _showRoleError,
              onRoleSelected: (role) => setState(() { _selectedRole = role; _showRoleError = false; }),
            ),
            const SizedBox(height: 32),
            PrimaryButton(text: "Kayıt Ol", onPressed: _register, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}
