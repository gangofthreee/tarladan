import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Uygulama renk sabitleri
class AppColors {
  static const Color primaryGreen = Color(0xFF3A5A40);
  static const Color lightGreen = Color(0xFF7CB342);
  static const Color darkText = Color(0xFF0D1117);
  static const Color errorRed = Colors.red;
  static const Color successGreen = Colors.green;
}

/// Türkiye telefon numarası formatter'ı
/// Format: 0 5XX XXX XX XX
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');

    // Minimum '0 5' olmalı
    if (text.isEmpty || text.length < 2) {
      return const TextEditingValue(
        text: '0 5',
        selection: TextSelection.collapsed(offset: 3),
      );
    }

    // '05' ile başlamalı
    if (!text.startsWith('05')) {
      return oldValue;
    }

    // Maksimum 11 rakam
    if (text.length > 11) {
      return oldValue;
    }

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);

      // Format: 0 5XX XXX XX XX
      if (i == 0) {
        buffer.write(' ');
      } else if (i == 3 && text.length > 4) {
        buffer.write(' ');
      } else if (i == 6 && text.length > 7) {
        buffer.write(' ');
      } else if (i == 8 && text.length > 9) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Şifre gereksinimleri widget'ı
class PasswordRequirements extends StatelessWidget {
  final String password;
  final bool showContainer;

  const PasswordRequirements({
    super.key,
    required this.password,
    this.showContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasMinLength = password.length >= 8;
    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RequirementItem(text: 'En az 8 karakter', isMet: hasMinLength),
        const SizedBox(height: 4),
        RequirementItem(text: 'Bir büyük harf (A-Z)', isMet: hasUpperCase),
        const SizedBox(height: 4),
        RequirementItem(text: 'Bir sayı (0-9)', isMet: hasNumber),
      ],
    );

    if (!showContainer) return content;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: content,
    );
  }
}

/// Tek gereksinim satırı
class RequirementItem extends StatelessWidget {
  final String text;
  final bool isMet;

  const RequirementItem({super.key, required this.text, required this.isMet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet ? AppColors.lightGreen : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? AppColors.lightGreen : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Rol seçim kartı widget'ı
class RoleSelectionCard extends StatelessWidget {
  final String role;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleSelectionCard({
    super.key,
    required this.role,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.9)
              : Colors.white.withOpacity(0.4),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.primaryGreen.withOpacity(0.5),
            width: isSelected ? 3.0 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              role,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primaryGreen : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Primary Action Button
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final EdgeInsets? padding;
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.padding,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightGreen,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

/// Custom App Bar for User screens
class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const UserAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: onBack != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
              onPressed: onBack ?? () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Styled TextField için InputDecoration builder
class AppInputDecoration {
  static InputDecoration standard({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool outlined = true,
    String? counterText,
  }) {
    if (outlined) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: counterText,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      );
    } else {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: counterText,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      );
    }
  }
}

/// Snackbar helper mixin
mixin SnackBarHelper<T extends StatefulWidget> on State<T> {
  void showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

/// Timer format helper
String formatTimer(int seconds) {
  int minutes = seconds ~/ 60;
  int remainingSeconds = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

/// Timer widget for verification screens
class CountdownTimer extends StatelessWidget {
  final int remainingSeconds;
  final bool isExpired;

  const CountdownTimer({
    super.key,
    required this.remainingSeconds,
    this.isExpired = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isExpired) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange, width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Doğrulama kodunuzun süresi doldu.',
                style: TextStyle(color: Colors.orange[900]),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGreen, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Text(
            'Kalan süre: ${formatTimer(remainingSeconds)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

/// Google Logo Painter
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 48;
    final scaleY = size.height / 48;
    final paint = Paint()..style = PaintingStyle.fill;

    // Kırmızı
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

    // Mavi
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

    // Sarı
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

    // Yeşil
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

/// Rol listesi sabiti
const List<Map<String, String>> kRoles = [
  {'label': 'Çiftçi', 'icon': '🌾', 'value': 'FARMER'},
  {'label': 'Müşteri', 'icon': '🛒', 'value': 'CUSTOMER'},
  {'label': 'Nakliyeci', 'icon': '🚚', 'value': 'TRUCKER'},
  {'label': 'Depo\nSahibi', 'icon': '🏭', 'value': 'DEPOT_OWNER'},
];

/// Login sayfası için rounded TextField
class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const LoginTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(prefixIcon, color: Colors.grey[600]),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

/// Google Sign In Button
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({super.key, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.5),
          side: BorderSide(color: Colors.white.withOpacity(0.8), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: isLoading ? null : onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
            else
              SizedBox(width: 24, height: 24, child: CustomPaint(painter: GoogleLogoPainter())),
            const SizedBox(width: 12),
            const Text(
              'Google ile giriş yap',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF555555)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Auth Link Row (örn: "Hesabın yok mu? Kaydol")
class AuthLinkRow extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onLinkTap;

  const AuthLinkRow({
    super.key,
    required this.text,
    required this.linkText,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: TextStyle(color: Colors.grey[700])),
        GestureDetector(
          onTap: onLinkTap,
          child: Text(linkText, style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

/// OTP Kod Input Widget - 6 haneli kod girişi için
class OtpCodeInput extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isExpired;
  final VoidCallback? onComplete;

  const OtpCodeInput({
    super.key,
    required this.controllers,
    required this.focusNodes,
    this.isExpired = false,
    this.onComplete,
  });

  String get code => controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (i) => _buildDigitField(i)),
    );
  }

  Widget _buildDigitField(int index) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isExpired ? Colors.red : AppColors.lightGreen)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightGreen)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) focusNodes[index + 1].requestFocus();
          if (value.isEmpty && index > 0) focusNodes[index - 1].requestFocus();
          if (index == 5 && value.isNotEmpty && code.length == 6) onComplete?.call();
        },
      ),
    );
  }
}

/// Email maskeleme yardımcı fonksiyonu
String maskEmail(String email) {
  if (!email.contains('@')) return email;
  final parts = email.split('@');
  final username = parts[0];
  final domain = parts[1];
  final masked = username.length > 2
      ? '${username.substring(0, 1)}${'*' * (username.length - 2)}${username.substring(username.length - 1)}'
      : username;
  return '$masked@$domain';
}

/// Password TextField with visibility toggle
class PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isObscure;
  final VoidCallback onToggle;

  const PasswordTextField({super.key, required this.controller, required this.label, required this.isObscure, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: AppColors.primaryGreen, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightGreen)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightGreen)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        suffixIcon: IconButton(icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey[600]), onPressed: onToggle),
      ),
    );
  }
}

/// Success Dialog with navigation
void showSuccessDialog(BuildContext context, {required String title, required String message, required String buttonText, required VoidCallback onPressed}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.lightGreen.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: AppColors.lightGreen, size: 50),
          ),
          const SizedBox(height: 24),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightGreen, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: onPressed,
            child: Text(buttonText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    ),
  );
}

/// Form Validators
class Validators {
  static String? required(String? value, String message) => (value == null || value.isEmpty) ? message : null;
  
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Lütfen e-posta adresinizi girin';
    if (!value.contains('@')) return 'Geçerli bir e-posta adresi girin';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Lütfen telefon numaranızı girin';
    final digits = value.replaceAll(' ', '');
    if (!RegExp(r'^[0-9]+$').hasMatch(digits)) return 'Sadece rakam giriniz';
    if (!digits.startsWith('05')) return 'Telefon 05 ile başlamalı';
    if (digits.length != 11) return '11 haneli olmalı';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Lütfen şifre girin';
    if (value.length < 8) return 'En az 8 karakter';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Bir büyük harf (A-Z)';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Bir sayı (0-9)';
    return null;
  }
}

/// Role Selection Grid Widget
class RoleSelectionGrid extends StatelessWidget {
  final String? selectedRole;
  final ValueChanged<String> onRoleSelected;
  final bool showError;

  const RoleSelectionGrid({super.key, this.selectedRole, required this.onRoleSelected, this.showError = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Rol Seçin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
        if (showError) Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(children: [
            Icon(Icons.error_outline, color: Colors.red[700], size: 18),
            const SizedBox(width: 6),
            Text("Lütfen bir rol seçin", style: TextStyle(color: Colors.red[700], fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
          children: kRoles.map((r) => RoleSelectionCard(
            role: r['label']!,
            icon: r['icon']!,
            isSelected: selectedRole == r['label'],
            onTap: () => onRoleSelected(r['label']!),
          )).toList(),
        ),
      ],
    );
  }
}

/// Underline styled TextFormField
class UnderlineTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Widget Function(BuildContext, {required int currentLength, required bool isFocused, int? maxLength})? buildCounter;

  const UnderlineTextField({
    super.key, required this.controller, required this.label, this.hint, this.keyboardType,
    this.obscureText = false, this.validator, this.inputFormatters, this.buildCounter,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.primaryGreen),
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: AppInputDecoration.standard(label: label, hint: hint, outlined: false),
      validator: validator,
      inputFormatters: inputFormatters,
      buildCounter: buildCounter,
    );
  }
}



