import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../config/api_config.dart';
import '../../services/session_service.dart';
import 'set_new_password_screen.dart';

class PasswordResetVerificationScreen extends StatefulWidget {
  final String email;

  const PasswordResetVerificationScreen({super.key, required this.email});

  @override
  State<PasswordResetVerificationScreen> createState() =>
      _PasswordResetVerificationScreenState();
}

class _PasswordResetVerificationScreenState
    extends State<PasswordResetVerificationScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isTimerExpired = false;
  bool _canResend = false;
  int _remainingSeconds = 180; // 3 dakika = 180 saniye
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 180;
      _isTimerExpired = false;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isTimerExpired = true;
          _canResend = true;
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

  String _getCode() {
    return _codeControllers.map((c) => c.text).join();
  }

  Future<void> _verifyResetCode() async {
    final code = _getCode();
    if (code.length != 6) {
      _showError('Lütfen 6 haneli kodu girin');
      return;
    }

    if (_isTimerExpired) {
      _showError('Süre doldu. Lütfen yeni bir kod isteyin.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/password-reset/confirm-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'resetCode': code}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Session cookie'yi kaydet
        final setCookie = response.headers['set-cookie'];
        if (setCookie != null) {
          SessionService.saveSessionCookie(setCookie);
        }

        // Kod doğrulandı - şifre belirleme ekranına git
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SetNewPasswordScreen()),
        );
      } else {
        _showError('Geçersiz kod, lütfen tekrar deneyin.');
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

  Future<void> _resendCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': widget.email}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSuccess('Yeni kod gönderildi');
        _startTimer();
        // Kod alanlarını temizle
        for (var controller in _codeControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      } else {
        _showError('Kod gönderilemedi. Lütfen tekrar deneyin.');
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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Email'i maskeleyerek göster
    String maskedEmail = widget.email;
    if (widget.email.contains('@')) {
      final parts = widget.email.split('@');
      final username = parts[0];
      final domain = parts[1];
      final maskedUsername = username.length > 2
          ? '${username.substring(0, 1)}${'*' * (username.length - 2)}${username.substring(username.length - 1)}'
          : username;
      maskedEmail = '$maskedUsername@$domain';
    }

    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Şifre Sıfırlama',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Kodu Girin',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1117),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$maskedEmail adresine gönderilen 6 haneli kodu girin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 40),
                  // 6 haneli kod giriş alanları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _codeControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _isTimerExpired
                                    ? Colors.red
                                    : const Color(0xFF00D563),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF00D563),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            }
                            if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                            // Otomatik doğrulama
                            if (index == 5 && value.isNotEmpty) {
                              final code = _getCode();
                              if (code.length == 6) {
                                _verifyResetCode();
                              }
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  // Timer ve mesaj
                  if (!_isTimerExpired)
                    Text(
                      'Kod geçerlilik süresi: ${_formatTime(_remainingSeconds)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _remainingSeconds < 60
                            ? Colors.red
                            : Colors.grey[600],
                        fontWeight: _remainingSeconds < 60
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    )
                  else
                    const Text(
                      'Geçersiz kod, lütfen tekrar deneyin.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 32),
                  // Kodu Onayla butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D563),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: (_isLoading || _isTimerExpired)
                          ? null
                          : _verifyResetCode,
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
                              'Kodu Onayla',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Kodu Tekrar Gönder butonu
                  TextButton(
                    onPressed: (_canResend && !_isLoading) ? _resendCode : null,
                    child: Text(
                      'Kodu Tekrar Gönder',
                      style: TextStyle(
                        fontSize: 16,
                        color: _canResend
                            ? const Color(0xFF00D563)
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
