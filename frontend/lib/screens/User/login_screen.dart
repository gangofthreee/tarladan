import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../../widgets/user_base_screen.dart';
import '../../widgets/farm_mascots.dart';
import '../../utils/page_transitions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isPasswordObscure = true;
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_updateState);
    _passwordFocusNode.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

        if (data['accessToken'] != null) {
          await TokenService.saveAccessToken(data['accessToken']);
        }
        if (data['refreshToken'] != null) {
          await TokenService.saveRefreshToken(data['refreshToken']);
        }

        if (!mounted) return;

        switch (role) {
          case 'FARMER':
            AppNavigator.pushReplacement(context, const FarmerMainPage(), transition: TransitionType.fade);
            break;
          case 'TRUCKER':
            AppNavigator.pushReplacement(context, const TruckerMainPage(), transition: TransitionType.fade);
            break;
          case 'CUSTOMER':
            AppNavigator.pushReplacement(context, const CustomerMainPage(), transition: TransitionType.fade);
            break;
          case 'DEPOT_OWNER':
            AppNavigator.pushReplacement(context, const WarehousemanMainPage(), transition: TransitionType.fade);
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
      final String? idToken = await _googleAuthService.signIn();

      if (idToken == null) {
        if (mounted) {
          setState(() {
            _isGoogleLoading = false;
          });
        }
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/google/verify-status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['isRegistered'] == true || data['registered'] == true) {
          final tokenResponse = data['tokenResponse'];
          if (tokenResponse != null) {
            await TokenService.saveAccessToken(tokenResponse['accessToken']);
            await TokenService.saveRefreshToken(tokenResponse['refreshToken']);
            await Future.delayed(const Duration(milliseconds: 500));

            if (!mounted) return;
            _navigateByRole(tokenResponse['role']);
          }
        } else {
          if (!mounted) return;
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GoogleRegisterScreen(idToken: idToken),
            ),
          );

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
    AppNavigator.pushReplacement(context, destination, transition: TransitionType.fade);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return UserBaseScreen(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'tarladan',
                style: GoogleFonts.spaceMono(
                  fontSize: 64,
                  color: const Color(0xFF3A5A40),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Mascots Animation
              AnimatedBuilder(
                animation: Listenable.merge([_emailFocusNode, _passwordFocusNode]),
                builder: (context, _) {
                  return FarmMascots(
                    isPasswordFocused: _passwordFocusNode.hasFocus,
                    isPasswordVisible: !_isPasswordObscure,
                    isEmailFocused: _emailFocusNode.hasFocus,
                  );
                },
              ),
              const SizedBox(height: 10),

              // Email Field
              TextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Email address',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: _isPasswordObscure,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscure = !_isPasswordObscure;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7CB342),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Giriş Yap',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Google Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.5),
                        side: BorderSide(color: Colors.white.withOpacity(0.8), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _isGoogleLoading ? null : _googleSignIn,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isGoogleLoading)
                            const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          else
                            SizedBox(width: 24, height: 24, child: CustomPaint(painter: GoogleLogoSvgPainter())),
                          const SizedBox(width: 12),
                          const Text(
                            'Google ile giriş yap',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Forgot Password?
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                    },
                    child: Text(
                      'Şifremi unuttum?',
                      style: TextStyle(color: Colors.grey[700],fontSize: 14),
                    ),
                  ),
                  
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Hesabın yok mu? ", style: TextStyle(color: Colors.grey[700])),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                        },
                        child: const Text(
                          "Kaydol",
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }
}

/// Google Logo SVG Painter
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
      ..cubicTo(27.54 * scaleX, 9.5 * scaleY, 30.71 * scaleX, 10.72 * scaleY, 33.21 * scaleX, 13.1 * scaleY)
      ..lineTo(40.06 * scaleX, 6.25 * scaleY)
      ..cubicTo(35.9 * scaleX, 2.38 * scaleY, 30.47 * scaleX, 0 * scaleY, 24 * scaleX, 0 * scaleY)
      ..cubicTo(14.62 * scaleX, 0 * scaleY, 6.51 * scaleX, 5.38 * scaleY, 2.56 * scaleX, 13.22 * scaleY)
      ..lineTo(10.54 * scaleX, 19.41 * scaleY)
      ..cubicTo(12.43 * scaleX, 13.72 * scaleY, 17.74 * scaleX, 9.5 * scaleY, 24 * scaleX, 9.5 * scaleY)
      ..close();
    canvas.drawPath(redPath, paint);

    // Mavi path (4285F4)
    paint.color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(46.98 * scaleX, 24.55 * scaleY)
      ..cubicTo(46.98 * scaleX, 22.98 * scaleY, 46.83 * scaleX, 21.46 * scaleY, 46.6 * scaleX, 20 * scaleY)
      ..lineTo(24 * scaleX, 20 * scaleY)
      ..lineTo(24 * scaleX, 29.02 * scaleY)
      ..lineTo(36.94 * scaleX, 29.02 * scaleY)
      ..cubicTo(36.36 * scaleX, 31.98 * scaleY, 34.68 * scaleX, 34.5 * scaleY, 32.16 * scaleX, 36.2 * scaleY)
      ..lineTo(39.89 * scaleX, 42.2 * scaleY)
      ..cubicTo(44.4 * scaleX, 38.02 * scaleY, 46.98 * scaleX, 31.84 * scaleY, 46.98 * scaleX, 24.55 * scaleY)
      ..close();
    canvas.drawPath(bluePath, paint);

    // Sarı path (FBBC05)
    paint.color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(10.53 * scaleX, 28.59 * scaleY)
      ..cubicTo(10.05 * scaleX, 27.14 * scaleY, 9.77 * scaleX, 25.6 * scaleY, 9.77 * scaleX, 24 * scaleY)
      ..cubicTo(9.77 * scaleX, 22.4 * scaleY, 10.04 * scaleX, 20.86 * scaleY, 10.53 * scaleX, 19.41 * scaleY)
      ..lineTo(2.55 * scaleX, 13.22 * scaleY)
      ..cubicTo(0.92 * scaleX, 16.46 * scaleY, 0 * scaleX, 20.12 * scaleY, 0 * scaleX, 24 * scaleY)
      ..cubicTo(0 * scaleX, 27.88 * scaleY, 0.92 * scaleX, 31.54 * scaleY, 2.56 * scaleX, 34.78 * scaleY)
      ..lineTo(10.53 * scaleX, 28.59 * scaleY)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Yeşil path (34A853)
    paint.color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(24 * scaleX, 48 * scaleY)
      ..cubicTo(30.48 * scaleX, 48 * scaleY, 35.93 * scaleX, 45.87 * scaleY, 39.89 * scaleX, 42.19 * scaleY)
      ..lineTo(32.16 * scaleX, 36.19 * scaleY)
      ..cubicTo(30.01 * scaleX, 37.64 * scaleY, 27.24 * scaleX, 38.49 * scaleY, 24 * scaleX, 38.49 * scaleY)
      ..cubicTo(17.74 * scaleX, 38.49 * scaleY, 12.43 * scaleX, 34.27 * scaleY, 10.53 * scaleX, 28.58 * scaleY)
      ..lineTo(2.55 * scaleX, 34.77 * scaleY)
      ..cubicTo(6.51 * scaleX, 42.62 * scaleY, 14.62 * scaleX, 48 * scaleY, 24 * scaleX, 48 * scaleY)
      ..close();
    canvas.drawPath(greenPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Farm Logo Widget
class FarmLogo extends StatelessWidget {
  const FarmLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
        ]
      ),
      child: ClipOval(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF9C4), Color(0xFFFFE0B2)], // Sun yellow to Warm Orange
            ),
          ),
          child: Stack(
            children: [
              // Sun
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 60, height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFCC80),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              // Hills
              Positioned.fill(
                child: CustomPaint(painter: HillsPainter()),
              ),
              // House
              Positioned(
                bottom: 45,
                right: 48,
                child: Icon(Icons.home_rounded, size: 45, color: Color(0xFF795548)),
              ),
               // Trees (Icons)
               Positioned(
                bottom: 50,
                left: 40,
                child: Icon(Icons.forest, size: 35, color: Color(0xFF2E7D32)),
               ),
            ],
          ),
        ),
      ),
    );
  }
}

class HillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Back Hill
    paint.color = const Color(0xFFA5D6A7);
    final path1 = Path();
    path1.moveTo(0, size.height * 0.6);
    path1.quadraticBezierTo(size.width * 0.25, size.height * 0.5, size.width * 0.6, size.height * 0.65);
    path1.quadraticBezierTo(size.width * 0.8, size.height * 0.75, size.width, size.height * 0.6);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint);

    // Front Hill
    paint.color = const Color(0xFF66BB6A);
    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(size.width * 0.4, size.height * 0.55, size.width, size.height * 0.8);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
