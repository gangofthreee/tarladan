import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../services/token_service.dart';
import '../../widgets/user_base_screen.dart';
import '../../widgets/user_widgets.dart';

class GoogleRegisterScreen extends StatefulWidget {
  final String idToken;
  const GoogleRegisterScreen({super.key, required this.idToken});
  @override
  State<GoogleRegisterScreen> createState() => _GoogleRegisterScreenState();
}

class _GoogleRegisterScreenState extends State<GoogleRegisterScreen> with SnackBarHelper {
  final _phone = TextEditingController(text: '0 5');
  String? _role;
  bool _isLoading = false;

  Future<void> _register() async {
    if (_role == null) return showErrorSnackBar('Lütfen bir rol seçin');
    final phone = _phone.text.replaceAll(' ', '');
    if (phone.length <= 2) return showErrorSnackBar('Telefon numaranızı girin');
    if (phone.length != 11 || !phone.startsWith('0')) return showErrorSnackBar('Geçerli telefon girin');

    setState(() => _isLoading = true);
    try {
      final res = await http.post(Uri.parse('${ApiConfig.baseUrl}/google/auth'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': widget.idToken, 'desiredRole': _role, 'phone': phone.trim()}));

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['accessToken'] != null) await TokenService.saveAccessToken(data['accessToken']);
        if (data['refreshToken'] != null) await TokenService.saveRefreshToken(data['refreshToken']);
        if (!mounted) return;
        Navigator.pop(context, {'success': true, 'role': data['role'] ?? _role});
      } else {
        showErrorSnackBar(json.decode(res.body)['message'] ?? 'Kayıt başarısız');
      }
    } catch (e) { showErrorSnackBar('Hata: $e'); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  void dispose() { _phone.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return UserBaseScreen(
      appBar: UserAppBar(title: 'Google ile Kayıt', onBack: () => Navigator.pop(context)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Hesap Türünüzü Seçin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkText)),
          const SizedBox(height: 8),
          const Text('Tarladan\'da nasıl kullanmak istediğinizi seçin', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),
          Expanded(child: GridView.count(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.2,
            children: kRoles.map((r) => _roleCard(r['label']!, r['icon']!, r['value']!, _role == r['value'])).toList(),
          )),
          const SizedBox(height: 24),
          const Text('Telefon', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _phone, keyboardType: TextInputType.phone, maxLength: 17,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, PhoneNumberFormatter()],
            decoration: InputDecoration(
              hintText: '0 5XX XXX XX XX', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
              counterText: '${_phone.text.replaceAll(' ', '').length}/11', counterStyle: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.lightGreen, width: 2)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.lightGreen, width: 2)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 1.2),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          PrimaryButton(text: 'Kaydı Tamamla', onPressed: _register, isLoading: _isLoading, borderRadius: 20),
        ]),
      ),
    );
  }

  Widget _roleCard(String label, String icon, String value, bool selected) => GestureDetector(
    onTap: () => setState(() => _role = value),
    child: Container(
      decoration: BoxDecoration(
        color: selected ? Colors.green.shade50.withOpacity(0.8) : Colors.white,
        border: Border.all(color: selected ? AppColors.lightGreen : Colors.grey.shade300, width: selected ? 2 : 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(icon, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: selected ? AppColors.primaryGreen : Colors.black87)),
      ]),
    ),
  );
}
