import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../config/api_config.dart';
import 'login_screen.dart';
import '../../widgets/user_base_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isTimerExpired = false;
  int _remainingSeconds = 120; // 2 dakika = 120 saniye
  Timer? _timer;

  // Resend code için yeni değişkenler
  bool _isResendLoading = false;
  bool _canResend = true;
  int _resendCooldown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isTimerExpired = true;
          timer.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) {
      _showErrorSnackBar("Lütfen doğrulama kodunu girin");
      return;
    }

    if (_isTimerExpired) {
      _showErrorSnackBar("Süre doldu. Lütfen yeni bir kod isteyin.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verifyCodeUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.email,
          'verificationCode': _codeController.text,
        }),
      );

      if (!mounted) return;

      print('Verification Response Status: ${response.statusCode}');
      print('Verification Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _timer?.cancel();
        _showSuccessDialog();
      } else {
        // Tüm hata durumları için aynı mesaj
        _showErrorSnackBar(
          "Doğrulama başarısız! Kod hatalı veya süresi dolmuş.",
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar("Bağlantı hatası: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Başarılı!'),
            ],
          ),
          content: const Text(
            'E-posta başarıyla doğrulandı!',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text('Giriş Yap', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _resendVerificationCode() async {
    if (!_canResend) {
      _showErrorSnackBar("Lütfen ${_resendCooldown} saniye bekleyin.");
      return;
    }

    setState(() {
      _isResendLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.resendCodeUrl(widget.email)),
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSuccessSnackBar("Yeni doğrulama kodu gönderildi!");

        // Timer'ı sıfırla ve yeniden başlat
        _timer?.cancel();
        setState(() {
          _remainingSeconds = 120;
          _isTimerExpired = false;
          _codeController.clear();
        });
        _startTimer();

        // 60 saniye cooldown başlat
        _startResendCooldown();
      } else {
        _showErrorSnackBar("Kod gönderilemedi. Lütfen tekrar deneyin.");
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar("Bağlantı hatası: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isResendLoading = false;
        });
      }
    }
  }

  void _startResendCooldown() {
    setState(() {
      _canResend = false;
      _resendCooldown = 120;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3A5A40)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "E-posta Doğrulama",
          style: TextStyle(color: Color(0xFF3A5A40), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      child: SingleChildScrollView( // Added scroll view to prevent overflow
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              "Doğrulama Kodu",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3A5A40)),
            ),
            const SizedBox(height: 16),
            Text(
              "E-posta adresinize (${widget.email}) gönderilen doğrulama kodunu girin.",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            // Zamanlayıcı göstergesi
            if (!_isTimerExpired)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7CB342), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: Color(0xFF3A5A40)),
                    const SizedBox(width: 8),
                    Text(
                      'Kalan süre: ${_formatTime(_remainingSeconds)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3A5A40),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              style: const TextStyle(color: Color(0xFF3A5A40), fontSize: 16),
              cursorColor: const Color(0xFF3A5A40),
              decoration: InputDecoration(
                labelText: 'Doğrulama Kodu',
                labelStyle: TextStyle(color: Colors.grey[700]),
                hintText: '6 haneli kod',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
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
                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              enabled: !_isLoading && !_isTimerExpired,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isLoading || _isTimerExpired) ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Green
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        "Onayla",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // Kodu Tekrar Gönder Butonu
            Center(
              child: TextButton.icon(
                onPressed: (_isResendLoading || !_isTimerExpired || !_canResend)
                    ? null
                    : _resendVerificationCode,
                icon: _isResendLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
                      )
                    : Icon(Icons.refresh, color: _canResend ? Colors.grey[700] : Colors.grey[400]),
                label: Text(
                  !_canResend
                      ? 'Tekrar gönder ($_resendCooldown sn)'
                      : 'Kodu Tekrar Gönder',
                  style: TextStyle(
                    fontSize: 16,
                    color: _canResend ? Colors.grey[700] : Colors.grey[400],
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[800],
                ),
              ),
            ),
            // Bilgilendirme mesajı
            if (!_isTimerExpired)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Kod yeniden gönderilebilmesi için ${_formatTime(_remainingSeconds)} beklemeniz gerekmektedir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (_isTimerExpired && _canResend)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Artık yeni bir doğrulama kodu talep edebilirsiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (!_canResend && _isTimerExpired)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Yeni kod göndermek için ${_formatTime(_resendCooldown)} beklemeniz gerekmektedir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (_isTimerExpired) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50], // Light orange
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Doğrulama kodunuzun süresi doldu.',
                        style: TextStyle(color: Colors.orange[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
