import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'verification_screen.dart';
import '../config/api_config.dart';

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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  final roles = [
    {'label': 'Çiftçi', 'icon': Icons.spa, 'value': 'FARMER'},
    {'label': 'Alıcı', 'icon': Icons.shopping_cart, 'value': 'BUYER'},
    {'label': 'Tırcı', 'icon': Icons.local_shipping, 'value': 'DRIVER'},
    {'label': 'Depocu', 'icon': Icons.apartment, 'value': 'DEPOT_OWNER'},
  ];

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
          content: Text("Lütfen bir rol seçin"),
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
      // Telefon numarasını 0 ile birleştir
      final fullPhoneNumber = '0${_phoneController.text.trim()}';

      print('API URL: ${ApiConfig.registerUrl}'); // Debug için
      print(
        'Gönderilen veri: ${jsonEncode({'name': _nameController.text.trim(), 'surname': _surnameController.text.trim(), 'email': _emailController.text.trim(), 'phone': fullPhoneNumber, 'password': _passwordController.text, 'role': _getRoleValue(selectedRole!)})}',
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
              throw Exception(
                'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.',
              );
            },
          );

      print('Response status: ${response.statusCode}'); // Debug için
      print('Response body: ${response.body}'); // Debug için

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Başarılı kayıt - verification ekranına yönlendir
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kayıt başarılı! E-postanızı kontrol edin."),
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
        // Hata durumu
        String errorMessage = 'Kayıt başarısız oldu';

        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            // Backend'den gelen error veya message alanını kontrol et
            if (errorData['error'] != null) {
              errorMessage = errorData['error'];
              // Email already in use hatası için Türkçe mesaj
              if (errorMessage.contains('Email already in use')) {
                errorMessage =
                    'Bu e-posta adresi zaten kullanılıyor. Lütfen farklı bir e-posta adresi deneyin.';
              }
            } else if (errorData['message'] != null) {
              errorMessage = errorData['message'];
            }
          } catch (e) {
            // JSON parse hatası durumunda default mesaj
            errorMessage = 'Kayıt başarısız oldu';
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

      print('Hata detayı: $e'); // Debug için

      String errorMessage = 'Bağlantı hatası: ';
      if (e.toString().contains('Failed host lookup')) {
        errorMessage +=
            'Sunucuya ulaşılamadı. Backend çalışıyor mu kontrol edin.';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage +=
            'Bağlantı reddedildi. Backend uygulaması çalışmıyor olabilir.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage +=
            'Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin.';
      } else if (e.toString().contains('timeout')) {
        errorMessage += 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';
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

  Widget buildRoleCard(String role, IconData icon) {
    final isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
          _showRoleError = false; // Rol seçildiğinde hatayı kaldır
        });
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.black87),
            const SizedBox(height: 8),
            Text(role, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tarladan'a Katıl",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Form Alanları
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ad'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen adınızı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _surnameController,
                decoration: const InputDecoration(labelText: 'Soyad'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen soyadınızı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  prefixText: '0',
                  hintText: '5XX XXX XX XX',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen telefon numaranızı girin';
                  }
                  // Sadece rakam kontrolü
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Sadece rakam giriniz';
                  }
                  // 10 hane kontrolü
                  if (value.length != 10) {
                    return 'Telefon numarası 10 haneli olmalıdır';
                  }
                  // 5 ile başlamalı (0'dan sonra)
                  if (!value.startsWith('5')) {
                    return 'Telefon numarası 5 ile başlamalıdır';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-posta'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen e-posta adresinizi girin';
                  }
                  if (!value.contains('@')) {
                    return 'Geçerli bir e-posta adresi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Parola'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen parola girin';
                  }
                  if (value.length < 6) {
                    return 'Parola en az 6 karakter olmalıdır';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                "Rolünü Seç",
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
                        "Lütfen bir rol seçin",
                        style: TextStyle(color: Colors.red[700], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Rol Seçimi Grid
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _showRoleError ? Colors.red : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 20,
                  runSpacing: 20,
                  children: roles
                      .map(
                        (r) => buildRoleCard(
                          r['label'] as String,
                          r['icon'] as IconData,
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 32),

              // Kayıt Ol Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
                          "Kayıt Ol",
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
      ),
    );
  }
}
