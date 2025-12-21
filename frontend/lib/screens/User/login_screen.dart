import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'google_register_screen.dart';
import '../../services/auth_service.dart';
import '../Farmer/farmer_main_page.dart';
import '../Trucker/trucker_main_page.dart';
import '../Warehouseman/warehouseman_main_page.dart';
import '../Customer/customer_main_page.dart';
import '../../widgets/user_base_screen.dart';
import '../../widgets/farm_mascots.dart';
import '../../widgets/user_widgets.dart';
import '../../utils/page_transitions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SnackBarHelper {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isLoading = false, _isGoogleLoading = false, _isPasswordObscure = true;

  static const _destinations = {'FARMER': FarmerMainPage(), 'TRUCKER': TruckerMainPage(), 'CUSTOMER': CustomerMainPage(), 'DEPOT_OWNER': WarehousemanMainPage()};

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
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
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return showErrorSnackBar('Lütfen tüm alanları doldurun');
    setState(() => _isLoading = true);
    final result = await AuthService.login(_emailController.text.trim(), _passwordController.text);
    if (mounted) setState(() => _isLoading = false);
    if (result.isSuccess) {
      _navigateByRole(result.role!);
    } else {
      showErrorSnackBar(result.error!);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isGoogleLoading = true);
    final result = await AuthService.googleSignIn();
    if (mounted) setState(() => _isGoogleLoading = false);
    
    if (result.isSuccess) {
      _navigateByRole(result.role!);
    } else if (result.needsRegistration && mounted) {
      final regResult = await Navigator.push(context, MaterialPageRoute(builder: (_) => GoogleRegisterScreen(idToken: result.idToken!)));
      if (regResult?['success'] == true) { _navigateByRole(regResult['role']); }
    } else if (result.error != null) {
      showErrorSnackBar(result.error!);
    }
  }

  void _navigateByRole(String role) {
    final dest = _destinations[role];
    if (dest != null) {
      AppNavigator.pushReplacement(context, dest, transition: TransitionType.fade);
    } else {
      showErrorSnackBar('Bilinmeyen kullanıcı rolü');
    }
  }

  void _push(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return UserBaseScreen(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            Text('tarladan', style: GoogleFonts.spaceMono(fontSize: 64, color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: Listenable.merge([_emailFocusNode, _passwordFocusNode]),
              builder: (_, __) => FarmMascots(isPasswordFocused: _passwordFocusNode.hasFocus, isPasswordVisible: !_isPasswordObscure, isEmailFocused: _emailFocusNode.hasFocus),
            ),
            const SizedBox(height: 10),
            LoginTextField(controller: _emailController, focusNode: _emailFocusNode, hintText: 'Email address', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            LoginTextField(
              controller: _passwordController, focusNode: _passwordFocusNode, hintText: 'Password', prefixIcon: Icons.lock_outline, obscureText: _isPasswordObscure,
              suffixIcon: IconButton(icon: Icon(_isPasswordObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey[600]), onPressed: () => setState(() => _isPasswordObscure = !_isPasswordObscure)),
            ),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Giriş Yap', onPressed: _login, isLoading: _isLoading, borderRadius: 30, padding: const EdgeInsets.symmetric(vertical: 18)),
            const SizedBox(height: 16),
            GoogleSignInButton(onPressed: _googleSignIn, isLoading: _isGoogleLoading),
            const SizedBox(height: 24),
            TextButton(onPressed: () => _push(const ForgotPasswordScreen()), child: Text('Şifremi unuttum?', style: TextStyle(color: Colors.grey[700], fontSize: 14))),
            AuthLinkRow(text: "Hesabın yok mu? ", linkText: "Kaydol", onLinkTap: () => _push(const RegisterScreen())),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}
