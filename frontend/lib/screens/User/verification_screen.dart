import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../config/api_config.dart';
import 'login_screen.dart';
import '../../widgets/user_base_screen.dart';
import '../../widgets/user_widgets.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});
  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> with SnackBarHelper {
  final _codeController = TextEditingController();
  bool _isLoading = false, _isTimerExpired = false, _isResendLoading = false, _canResend = true;
  int _remainingSeconds = 120, _resendCooldown = 0;
  Timer? _timer, _resendTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        setState(() => _isTimerExpired = true);
        t.cancel();
      }
    });
  }

  Future<void> _verify() async {
    if (_codeController.text.isEmpty) return showErrorSnackBar("Lütfen kodu girin");
    if (_isTimerExpired) return showErrorSnackBar("Süre doldu. Yeni kod isteyin.");

    setState(() => _isLoading = true);
    try {
      final res = await http.post(Uri.parse(ApiConfig.verifyCodeUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': widget.email, 'verificationCode': _codeController.text}));
      if (!mounted) return;
      if (res.statusCode == 200) {
        _timer?.cancel();
        showSuccessDialog(context, title: 'Başarılı!', message: 'E-posta doğrulandı.', buttonText: 'Giriş Yap',
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false));
      } else {
        showErrorSnackBar("Kod hatalı veya süresi dolmuş.");
      }
    } catch (e) { showErrorSnackBar("Bağlantı hatası: $e"); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _resend() async {
    if (!_canResend) return showErrorSnackBar("$_resendCooldown saniye bekleyin.");
    setState(() => _isResendLoading = true);
    try {
      final res = await http.post(Uri.parse(ApiConfig.resendCodeUrl(widget.email)), headers: {'Content-Type': 'application/json'});
      if (!mounted) return;
      if (res.statusCode == 200) {
        showSuccessSnackBar("Yeni kod gönderildi!");
        _timer?.cancel();
        setState(() { _remainingSeconds = 120; _isTimerExpired = false; _codeController.clear(); });
        _startTimer();
        _startResendCooldown();
      } else { showErrorSnackBar("Kod gönderilemedi."); }
    } catch (e) { showErrorSnackBar("Bağlantı hatası: $e"); }
    finally { if (mounted) setState(() => _isResendLoading = false); }
  }

  void _startResendCooldown() {
    setState(() { _canResend = false; _resendCooldown = 120; });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCooldown > 0) { setState(() => _resendCooldown--); }
      else { setState(() => _canResend = true); t.cancel(); }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resendTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UserBaseScreen(
      appBar: UserAppBar(title: "E-posta Doğrulama", onBack: () => Navigator.pop(context)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 24),
          const Text("Doğrulama Kodu", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
          const SizedBox(height: 16),
          Text("E-posta adresinize (${widget.email}) gönderilen kodu girin.", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          const SizedBox(height: 24),
          if (!_isTimerExpired) CountdownTimer(remainingSeconds: _remainingSeconds),
          const SizedBox(height: 24),
          TextField(
            controller: _codeController,
            style: const TextStyle(color: AppColors.primaryGreen, fontSize: 16),
            decoration: AppInputDecoration.standard(label: 'Doğrulama Kodu', hint: '6 haneli kod', prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600])),
            keyboardType: TextInputType.number,
            maxLength: 6,
            enabled: !_isLoading && !_isTimerExpired,
          ),
          const SizedBox(height: 24),
          PrimaryButton(text: "Onayla", onPressed: (_isLoading || _isTimerExpired) ? null : _verify, isLoading: _isLoading),
          const SizedBox(height: 16),
          Center(child: TextButton.icon(
            onPressed: (_isResendLoading || !_isTimerExpired || !_canResend) ? null : _resend,
            icon: _isResendLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey)) : Icon(Icons.refresh, color: _canResend ? Colors.grey[700] : Colors.grey[400]),
            label: Text(!_canResend ? 'Tekrar gönder ($_resendCooldown sn)' : 'Kodu Tekrar Gönder', style: TextStyle(fontSize: 16, color: _canResend ? Colors.grey[700] : Colors.grey[400])),
          )),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(
            !_isTimerExpired ? 'Yeni kod gönderilmesi için ${formatTimer(_remainingSeconds)} bekleyin.' : (_canResend ? 'Yeni kod talep edebilirsiniz.' : 'Yeni kod için ${formatTimer(_resendCooldown)} bekleyin.'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: !_isTimerExpired ? Colors.grey[600] : (_canResend ? Colors.green[700] : Colors.orange[700]), fontStyle: _canResend ? FontStyle.normal : FontStyle.italic),
          )),
          if (_isTimerExpired) ...[const SizedBox(height: 16), CountdownTimer(remainingSeconds: 0, isExpired: true)],
        ]),
      ),
    );
  }
}
