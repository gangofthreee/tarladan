import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../config/api_config.dart';
import '../../services/session_service.dart';
import 'set_new_password_screen.dart';
import '../../widgets/user_base_screen.dart';
import '../../widgets/user_widgets.dart';

class PasswordResetVerificationScreen extends StatefulWidget {
  final String email;
  const PasswordResetVerificationScreen({super.key, required this.email});
  @override
  State<PasswordResetVerificationScreen> createState() => _PasswordResetVerificationScreenState();
}

class _PasswordResetVerificationScreenState extends State<PasswordResetVerificationScreen> with SnackBarHelper {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false, _isTimerExpired = false, _canResend = false;
  int _remainingSeconds = 180;
  Timer? _timer;

  String get _code => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() { _remainingSeconds = 180; _isTimerExpired = false; _canResend = false; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        setState(() { _isTimerExpired = true; _canResend = true; });
        t.cancel();
      }
    });
  }

  Future<void> _verify() async {
    if (_code.length != 6) return showErrorSnackBar('Lütfen 6 haneli kodu girin');
    if (_isTimerExpired) return showErrorSnackBar('Süre doldu. Lütfen yeni kod isteyin.');
    setState(() => _isLoading = true);
    try {
      final res = await http.post(Uri.parse('${ApiConfig.baseUrl}/auth/password-reset/confirm-code'),
        headers: {'Content-Type': 'application/json'}, body: json.encode({'resetCode': _code}));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final cookie = res.headers['set-cookie'];
        if (cookie != null) SessionService.saveSessionCookie(cookie);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SetNewPasswordScreen()));
      } else {
        showErrorSnackBar('Geçersiz kod, lütfen tekrar deneyin.');
      }
    } catch (e) { showErrorSnackBar('Bağlantı hatası: $e'); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _resend() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.post(Uri.parse('${ApiConfig.baseUrl}/auth/password-reset'),
        headers: {'Content-Type': 'application/json'}, body: json.encode({'email': widget.email}));
      if (!mounted) return;
      if (res.statusCode == 200) {
        showSuccessSnackBar('Yeni kod gönderildi');
        _startTimer();
        for (var c in _controllers) { c.clear(); }
        _focusNodes[0].requestFocus();
      } else { showErrorSnackBar('Kod gönderilemedi.'); }
    } catch (e) { showErrorSnackBar('Bağlantı hatası: $e'); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) { c.dispose(); }
    for (var n in _focusNodes) { n.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UserBaseScreen(
      appBar: UserAppBar(title: 'Şifre Sıfırlama', onBack: () => Navigator.pop(context)),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const Text('Kodu Girin', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkText)),
            const SizedBox(height: 16),
            Text('${maskEmail(widget.email)} adresine gönderilen 6 haneli kodu girin.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
            const SizedBox(height: 40),
            OtpCodeInput(controllers: _controllers, focusNodes: _focusNodes, isExpired: _isTimerExpired, onComplete: _verify),
            const SizedBox(height: 24),
            Text(_isTimerExpired ? 'Kod süresi doldu.' : 'Kalan süre: ${formatTimer(_remainingSeconds)}',
              style: TextStyle(fontSize: 14, color: _isTimerExpired || _remainingSeconds < 60 ? Colors.red : Colors.grey[600], fontWeight: _remainingSeconds < 60 ? FontWeight.bold : FontWeight.normal)),
            const SizedBox(height: 32),
            PrimaryButton(text: 'Kodu Onayla', onPressed: (_isLoading || _isTimerExpired) ? null : _verify, isLoading: _isLoading, borderRadius: 24),
            const SizedBox(height: 16),
            TextButton(onPressed: (_canResend && !_isLoading) ? _resend : null, 
              child: Text('Kodu Tekrar Gönder', style: TextStyle(fontSize: 16, color: _canResend ? AppColors.lightGreen : Colors.grey, fontWeight: FontWeight.bold))),
          ]),
        ),
      ),
    );
  }
}
