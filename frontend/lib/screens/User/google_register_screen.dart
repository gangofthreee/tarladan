import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../services/token_service.dart';

class GoogleRegisterScreen extends StatefulWidget {
  final String idToken;

  const GoogleRegisterScreen({
    super.key,
    required this.idToken,
  });

  @override
  State<GoogleRegisterScreen> createState() => _GoogleRegisterScreenState();
}

class _GoogleRegisterScreenState extends State<GoogleRegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;

  final List<Map<String, String>> _roles = [
    {'value': 'FARMER', 'label': 'Çiftçi', 'icon': '🌾'},
    {'value': 'TRUCKER', 'label': 'Nakliyeci', 'icon': '🚚'},
    {'value': 'CUSTOMER', 'label': 'Müşteri', 'icon': '🛒'},
    {'value': 'DEPOT_OWNER', 'label': 'Depo Sahibi', 'icon': '🏭'},
  ];

  Future<void> _register() async {
    if (_selectedRole == null) {
      _showError('Lütfen bir rol seçin');
      return;
    }

    if (_phoneController.text.isEmpty) {
      _showError('Lütfen telefon numaranızı girin');
      return;
    }

    final phone = _phoneController.text.replaceAll(' ', '');
    if (phone.length != 10) {
      _showError('Telefon numarası 10 haneli olmalıdır');
      return;
    }

    if (!phone.startsWith('05')) {
      _showError('Telefon numarası 05 ile başlamalıdır');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/google/auth'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'idToken': widget.idToken,
          'desiredRole': _selectedRole,
          'phone': _phoneController.text.replaceAll(' ', '').trim(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);

        // Token'ları kaydet
        if (data['accessToken'] != null) {
          await TokenService.saveAccessToken(data['accessToken']);
        }
        if (data['refreshToken'] != null) {
          await TokenService.saveRefreshToken(data['refreshToken']);
        }

        if (!mounted) return;

        // Başarılı kayıt - Geri dön ve role bilgisini gönder
        Navigator.pop(context, {
          'success': true,
          'role': data['role'] ?? _selectedRole,
        });
      } else {
        final data = json.decode(response.body);
        _showError(data['message'] ?? 'Kayıt başarısız');
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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            'Google ile Kayıt',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hesap Türünüzü Seçin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1117),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tarladan\'da nasıl kullanmak istediğinizi seçin',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              
              // Role seçimi
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _roles.length,
                  itemBuilder: (context, index) {
                    final role = _roles[index];
                    final isSelected = _selectedRole == role['value'];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRole = role['value'];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green.shade50 : Colors.white,
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              role['icon']!,
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              role['label']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.green : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Telefon numarası
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Telefon',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 13, // 05XX XXX XX XX = 13 karakter
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _PhoneNumberFormatter(),
                    ],
                    decoration: InputDecoration(
                      hintText: '05XX XXX XX XX',
                      hintStyle: const TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 16,
                      ),
                      counterText: '${_phoneController.text.replaceAll(' ', '').length}/10',
                      counterStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 0,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                    onChanged: (value) {
                      setState(() {}); // Counter'ı güncellemek için
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Kayıt butonu
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
                  onPressed: _isLoading ? null : _register,
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
                          'Kaydı Tamamla',
                          style: TextStyle(
                            fontSize: 18,
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

/// Türkiye telefon numarası formatter'ı
/// Format: 05XX XXX XX XX
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    
    if (text.isEmpty) {
      return newValue;
    }

    // Maksimum 10 rakam
    if (text.length > 10) {
      return oldValue;
    }

    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      
      // 4. rakamdan sonra boşluk (05XX XXX)
      if (i == 3 && text.length > 4) {
        buffer.write(' ');
      }
      // 7. rakamdan sonra boşluk (05XX XXX XX)
      else if (i == 6 && text.length > 7) {
        buffer.write(' ');
      }
      // 9. rakamdan sonra boşluk (05XX XXX XX XX)
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
