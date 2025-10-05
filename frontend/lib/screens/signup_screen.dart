import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? selectedRole;

  final roles = [
    {'label': 'Çiftçi', 'icon': Icons.spa},
    {'label': 'Alıcı', 'icon': Icons.shopping_cart},
    {'label': 'Tırcı', 'icon': Icons.local_shipping},
    {'label': 'Depocu', 'icon': Icons.apartment},
  ];

  Widget buildRoleCard(String role, IconData icon) {
    final isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() => selectedRole = role);
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
        child: ListView(
          children: [
            // Form Alanları
            const TextField(decoration: InputDecoration(labelText: 'Ad')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Soyad')),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Telefon'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'E-posta'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Parola'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            const Text(
              "Rolünü Seç",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Rol Seçimi Grid
            Wrap(
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
            const SizedBox(height: 32),

            // Kayıt Ol Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Burada kayıt işlemini tetikle
                  if (selectedRole == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Lütfen bir rol seçin")),
                    );
                  } else {
                    // Kayıt işlemleri
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Kayıt Ol",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
