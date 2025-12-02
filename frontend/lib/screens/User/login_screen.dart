import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'google_register_screen.dart';
import '../../config/api_config.dart';
import '../../services/token_service.dart';
import '../../services/google_auth_service.dart';
import '../Farmer/farmer_main_page.dart';
import '../Trucker/trucker_main_page.dart';
import '../Warehouseman/warehouseman_main_page.dart';
import '../Customer/customer_main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Lütfen tüm alanları doldurun');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String role = data['role'];

        // JWT token'ları kaydet
        if (data['accessToken'] != null) {
          await TokenService.saveAccessToken(data['accessToken']);
        }
        if (data['refreshToken'] != null) {
          await TokenService.saveRefreshToken(data['refreshToken']);
        }

        if (!mounted) return;

        // Role'e göre yönlendirme
        switch (role) {
          case 'FARMER':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FarmerMainPage()),
            );
            break;
          case 'TRUCKER':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TruckerMainPage()),
            );
            break;
          case 'CUSTOMER':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CustomerMainPage()),
            );
            break;
          case 'DEPOT_OWNER':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const WarehousemanMainPage(),
              ),
            );
            break;
          default:
            _showError('Bilinmeyen kullanıcı rolü');
        }
      } else {
        _showError('Giriş başarısız. Lütfen bilgilerinizi kontrol edin.');
      }
    } catch (e) {
      _showError('Bir hata oluştu: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      // Google Sign-In ile ID token al
      final String? idToken = await _googleAuthService.signIn();

      if (idToken == null) {
        // Kullanıcı işlemi iptal etti
        if (mounted) {
          setState(() {
            _isGoogleLoading = false;
          });
        }
        return;
      }

      // Backend'e ID token gönder - Kullanıcı kayıtlı mı kontrol et
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/google/verify-status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('Google verify-status response: $data');

        // Backend 'isRegistered' döndürüyor, 'registered' değil
        if (data['isRegistered'] == true || data['registered'] == true) {
          // Kullanıcı kayıtlı - Token'ları kaydet ve giriş yap
          final tokenResponse = data['tokenResponse'];

          print('Google login tokenResponse: $tokenResponse');

          if (tokenResponse != null) {
            print(
              'Saving Google tokens - Access: ${tokenResponse['accessToken']?.substring(0, 20)}...',
            );
            await TokenService.saveAccessToken(tokenResponse['accessToken']);
            await TokenService.saveRefreshToken(tokenResponse['refreshToken']);

            // Token kaydedildi mi kontrol et
            final savedToken = await TokenService.getAccessToken();
            print(
              'Token kaydedildi mi kontrol: ${savedToken?.substring(0, 20)}...',
            );

            // Token'ın backend'de aktif olması için kısa bir bekleme
            await Future.delayed(const Duration(milliseconds: 500));

            if (!mounted) return;
            _navigateByRole(tokenResponse['role']);
          } else {
            print('tokenResponse is null!');
          }
        } else {
          // Kullanıcı kayıtlı değil - Kayıt ekranına yönlendir
          if (!mounted) return;

          // Role ve telefon seçim ekranına git
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GoogleRegisterScreen(idToken: idToken),
            ),
          );

          // Kayıt başarılıysa ana sayfaya yönlendir
          if (result != null && result['success'] == true) {
            _navigateByRole(result['role']);
          }
        }
      } else {
        _showError('Google ile giriş başarısız.');
      }
    } catch (e) {
      _showError('Google giriş hatası: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _navigateByRole(String role) {
    Widget destination;

    switch (role) {
      case 'FARMER':
        destination = const FarmerMainPage();
        break;
      case 'TRUCKER':
        destination = const TruckerMainPage();
        break;
      case 'CUSTOMER':
        destination = const CustomerMainPage();
        break;
      case 'DEPOT_OWNER':
        destination = const WarehousemanMainPage();
        break;
      default:
        _showError('Bilinmeyen kullanıcı rolü');
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'tarladan',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1117),
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'E-posta',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Parola',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Şifremi Unuttum',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _isLoading ? null : _login,
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
                              'Giriş Yap',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('veya'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      height: 40,
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                        minWidth: 200,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131314),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF8E918F),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isGoogleLoading ? null : _googleSignIn,
                          borderRadius: BorderRadius.circular(20),
                          splashColor: Colors.white.withOpacity(0.12),
                          highlightColor: Colors.white.withOpacity(0.08),
                          hoverColor: Colors.white.withOpacity(0.08),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isGoogleLoading)
                                  const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFE3E3E3),
                                      ),
                                    ),
                                  )
                                else
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CustomPaint(
                                      painter: GoogleLogoSvgPainter(),
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Google ile giriş yap',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFE3E3E3),
                                    letterSpacing: 0.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.apple),
                    label: const Text('Apple ile Giriş Yap'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Hesabın yok mu?'),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Kaydol',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ], // children of Column
              ), // Column
            ), // SingleChildScrollView
          ), // Center
        ), // Padding (body of Scaffold)
      ), // Scaffold (child of Theme)
    ); // Theme
  }
}

/// Google Logo SVG Painter - Google'ın resmi SVG path'lerini kullanır
class GoogleLogoSvgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 48;
    final scaleY = size.height / 48;
    final paint = Paint()..style = PaintingStyle.fill;

    // Kırmızı path (EA4335)
    paint.color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(24 * scaleX, 9.5 * scaleY)
      ..cubicTo(
        27.54 * scaleX,
        9.5 * scaleY,
        30.71 * scaleX,
        10.72 * scaleY,
        33.21 * scaleX,
        13.1 * scaleY,
      )
      ..lineTo(40.06 * scaleX, 6.25 * scaleY)
      ..cubicTo(
        35.9 * scaleX,
        2.38 * scaleY,
        30.47 * scaleX,
        0 * scaleY,
        24 * scaleX,
        0 * scaleY,
      )
      ..cubicTo(
        14.62 * scaleX,
        0 * scaleY,
        6.51 * scaleX,
        5.38 * scaleY,
        2.56 * scaleX,
        13.22 * scaleY,
      )
      ..lineTo(10.54 * scaleX, 19.41 * scaleY)
      ..cubicTo(
        12.43 * scaleX,
        13.72 * scaleY,
        17.74 * scaleX,
        9.5 * scaleY,
        24 * scaleX,
        9.5 * scaleY,
      )
      ..close();
    canvas.drawPath(redPath, paint);

    // Mavi path (4285F4)
    paint.color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(46.98 * scaleX, 24.55 * scaleY)
      ..cubicTo(
        46.98 * scaleX,
        22.98 * scaleY,
        46.83 * scaleX,
        21.46 * scaleY,
        46.6 * scaleX,
        20 * scaleY,
      )
      ..lineTo(24 * scaleX, 20 * scaleY)
      ..lineTo(24 * scaleX, 29.02 * scaleY)
      ..lineTo(36.94 * scaleX, 29.02 * scaleY)
      ..cubicTo(
        36.36 * scaleX,
        31.98 * scaleY,
        34.68 * scaleX,
        34.5 * scaleY,
        32.16 * scaleX,
        36.2 * scaleY,
      )
      ..lineTo(39.89 * scaleX, 42.2 * scaleY)
      ..cubicTo(
        44.4 * scaleX,
        38.02 * scaleY,
        46.98 * scaleX,
        31.84 * scaleY,
        46.98 * scaleX,
        24.55 * scaleY,
      )
      ..close();
    canvas.drawPath(bluePath, paint);

    // Sarı path (FBBC05)
    paint.color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(10.53 * scaleX, 28.59 * scaleY)
      ..cubicTo(
        10.05 * scaleX,
        27.14 * scaleY,
        9.77 * scaleX,
        25.6 * scaleY,
        9.77 * scaleX,
        24 * scaleY,
      )
      ..cubicTo(
        9.77 * scaleX,
        22.4 * scaleY,
        10.04 * scaleX,
        20.86 * scaleY,
        10.53 * scaleX,
        19.41 * scaleY,
      )
      ..lineTo(2.55 * scaleX, 13.22 * scaleY)
      ..cubicTo(
        0.92 * scaleX,
        16.46 * scaleY,
        0 * scaleX,
        20.12 * scaleY,
        0 * scaleX,
        24 * scaleY,
      )
      ..cubicTo(
        0 * scaleX,
        27.88 * scaleY,
        0.92 * scaleX,
        31.54 * scaleY,
        2.56 * scaleX,
        34.78 * scaleY,
      )
      ..lineTo(10.53 * scaleX, 28.59 * scaleY)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Yeşil path (34A853)
    paint.color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(24 * scaleX, 48 * scaleY)
      ..cubicTo(
        30.48 * scaleX,
        48 * scaleY,
        35.93 * scaleX,
        45.87 * scaleY,
        39.89 * scaleX,
        42.19 * scaleY,
      )
      ..lineTo(32.16 * scaleX, 36.19 * scaleY)
      ..cubicTo(
        30.01 * scaleX,
        37.64 * scaleY,
        27.24 * scaleX,
        38.49 * scaleY,
        24 * scaleX,
        38.49 * scaleY,
      )
      ..cubicTo(
        17.74 * scaleX,
        38.49 * scaleY,
        12.43 * scaleX,
        34.27 * scaleY,
        10.53 * scaleX,
        28.58 * scaleY,
      )
      ..lineTo(2.55 * scaleX, 34.77 * scaleY)
      ..cubicTo(
        6.51 * scaleX,
        42.62 * scaleY,
        14.62 * scaleX,
        48 * scaleY,
        24 * scaleX,
        48 * scaleY,
      )
      ..close();
    canvas.drawPath(greenPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
