import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'verification_screen.dart';
import '../../config/api_config.dart';
import '../../widgets/user_base_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? selectedRole;
  final _formKey = GlobalKey<FormState>();
  bool _showRoleError = false;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(
    text: '0 5',
  );
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  final roles = [
    {'label': 'Farmer', 'icon': '🌾', 'value': 'FARMER'},
    {'label': 'Customer', 'icon': '🛒', 'value': 'CUSTOMER'},
    {'label': 'Trucker', 'icon': '🚚', 'value': 'TRUCKER'},
    {'label': 'Warehouse\nOwner', 'icon': '🏭', 'value': 'DEPOT_OWNER'},
  ];

  @override
  void initState() {
    super.initState();
    // Password değişikliklerini dinle
    _passwordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _getRoleValue(String label) {
    final role = roles.firstWhere((r) => r['label'] == label);
    return role['value'] as String?;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedRole == null) {
      setState(() {
        _showRoleError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a role"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _showRoleError = false;
    });

    try {
      // Get phone number without spaces
      final fullPhoneNumber = _phoneController.text.replaceAll(' ', '').trim();

      print('API URL: ${ApiConfig.registerUrl}'); // For debugging
      print(
        'Sent data: ${jsonEncode({'name': _nameController.text.trim(), 'surname': _surnameController.text.trim(), 'email': _emailController.text.trim(), 'phone': fullPhoneNumber, 'password': _passwordController.text, 'role': _getRoleValue(selectedRole!)})}',
      );

      final response = await http
          .post(
            Uri.parse(ApiConfig.registerUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': _nameController.text.trim(),
              'surname': _surnameController.text.trim(),
              'email': _emailController.text.trim(),
              'phone': fullPhoneNumber,
              'password': _passwordController.text,
              'role': _getRoleValue(selectedRole!),
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Connection timed out. Please try again.');
            },
          );

      print('Response status: ${response.statusCode}'); // For debugging
      print('Response body: ${response.body}'); // For debugging

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successful registration - redirect to verification screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration successful! Check your email."),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VerificationScreen(email: _emailController.text.trim()),
          ),
        );
      } else {
        // Error case
        String errorMessage = 'Registration failed';

        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            // Check error or message field from backend
            if (errorData['error'] != null) {
              errorMessage = errorData['error'];
              // Email already in use error message
              if (errorMessage.contains('Email already in use')) {
                errorMessage =
                    'This email address is already in use. Please try a different email address.';
              }
            } else if (errorData['message'] != null) {
              errorMessage = errorData['message'];
            }
          } catch (e) {
            // Default message in case of JSON parse error
            errorMessage = 'Registration failed';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      print('Error details: $e'); // For debugging

      String errorMessage = 'Connection error: ';
      if (e.toString().contains('Failed host lookup')) {
        errorMessage += 'Could not reach server. Check if backend is running.';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage +=
            'Connection refused. Backend application may not be running.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage +=
            'Network connection error. Check your internet connection.';
      } else if (e.toString().contains('timeout')) {
        errorMessage += 'Request timed out. Please try again.';
      } else {
        errorMessage += e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget buildRoleCard(String role, String icon) {
    final isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
          _showRoleError = false; // Remove error when role is selected
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.4),
          border: Border.all(
            color: isSelected ? const Color(0xFF3A5A40) : const Color(0xFF3A5A40).withOpacity(0.5),
            width: isSelected ? 3.0 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3A5A40).withOpacity(0.2),
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
                color: isSelected ? const Color(0xFF3A5A40) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
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
          "Join Tarladan",
          style: TextStyle(
            color: Color(0xFF3A5A40),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: [
            // Form Fields
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _surnameController,
              decoration: const InputDecoration(labelText: 'Surname'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your surname';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: '0 5XX XXX XX XX',
              ),
              keyboardType: TextInputType.phone,
              maxLength: 15,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
                _SignupPhoneNumberFormatter(),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                final digitsOnly = value.replaceAll(' ', '');
                // Only digits check
                if (!RegExp(r'^[0-9]+$').hasMatch(digitsOnly)) {
                  return 'Only digits allowed';
                }
                // Must start with 05
                if (!digitsOnly.startsWith('05')) {
                  return 'Phone number must start with 05';
                }
                // 11 digits check (05 + 9 more)
                if (digitsOnly.length != 11) {
                  return 'Phone number must be 11 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                if (value.length < 8) {
                  return 'En az 8 karakter';
                }
                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return 'Bir büyük harf (A-Z)';
                }
                if (!RegExp(r'[0-9]').hasMatch(value)) {
                  return 'Bir sayı (0-9)';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            _PasswordRequirements(password: _passwordController.text),
            const SizedBox(height: 24),
            const Text(
              "Select Role",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_showRoleError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[700],
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Please select a role",
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Role Selection Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: roles
                  .map(
                    (r) => buildRoleCard(
                      r['label'] as String,
                      r['icon'] as String,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 32),

            // Register Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7CB342), // Green from login
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                        "Register",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignupPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');

    // Always start with "05"
    if (text.isEmpty || text.length < 2) {
      return const TextEditingValue(
        text: '0 5',
        selection: TextSelection.collapsed(offset: 3),
      );
    }

    // Must start with 05
    if (!text.startsWith('05')) {
      return oldValue;
    }

    // Maximum 11 digits (0 + 5 + 9 more)
    if (text.length > 11) {
      return oldValue;
    }

    final buffer = StringBuffer();

    // Format: 0 5XX XXX XX XX
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);

      // After 1st digit (0) add space
      if (i == 0) {
        buffer.write(' ');
      }
      // After 4th digit (0 5XX) add space
      else if (i == 3 && text.length > 4) {
        buffer.write(' ');
      }
      // After 7th digit (0 5XX XXX) add space
      else if (i == 6 && text.length > 7) {
        buffer.write(' ');
      }
      // After 9th digit (0 5XX XXX XX) add space
      else if (i == 8 && text.length > 9) {
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

// Password Requirements Widget
class _PasswordRequirements extends StatelessWidget {
  final String password;

  const _PasswordRequirements({required this.password});

  @override
  Widget build(BuildContext context) {
    final hasMinLength = password.length >= 8;
    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequirementItem(text: 'En az 8 karakter', isMet: hasMinLength),
        _RequirementItem(text: 'Bir büyük harf (A-Z)', isMet: hasUpperCase),
        _RequirementItem(text: 'Bir sayı (0-9)', isMet: hasNumber),
      ],
    );
  }
}

// Individual Requirement Item
class _RequirementItem extends StatelessWidget {
  final String text;
  final bool isMet;

  const _RequirementItem({required this.text, required this.isMet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
