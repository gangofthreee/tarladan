import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/user_widgets.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _user;
  String? _error;

  static const _roles = {'FARMER': 'Çiftçi', 'TRUCKER': 'Nakliyeci', 'CUSTOMER': 'Müşteri', 'WAREHOUSEMAN': 'Depocu', 'DEPOT_OWNER': 'Depocu'};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      _user = await UserService.getUserInfo();
    } catch (_) {
      _error = 'Profil yüklenemedi';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ThemedScaffold(
      useGradientBackground: true,
      appBar: ThemedAppBar(title: const Text('Profil Bilgileri', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, elevation: 0, backgroundColor: Colors.transparent),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.lightGreen))
          : _error != null
              ? _buildError()
              : RefreshIndicator(onRefresh: _load, color: AppColors.lightGreen, child: _buildContent(isDark)),
    );
  }

  Widget _buildError() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
      const SizedBox(height: 16),
      Text(_error!, style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Tekrar Dene'),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
      ),
    ]),
  );

  Widget _buildContent(bool isDark) => SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(20),
    child: Column(children: [
      Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.lightGreen.withOpacity(0.2)), child: const Icon(Icons.person, size: 50, color: AppColors.lightGreen)),
      const SizedBox(height: 24),
      Text('${_user?['name'] ?? ''} ${_user?['surname'] ?? ''}'.trim(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(color: AppColors.lightGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
        child: Text(_roles[_user?['role']] ?? _user?['role'] ?? 'Bilinmiyor', style: const TextStyle(color: AppColors.lightGreen, fontWeight: FontWeight.w600, fontSize: 14)),
      ),
      const SizedBox(height: 32),
      _infoCard(Icons.email_outlined, 'E-posta', _user?['email'] ?? '-', isDark, verified: _user?['isMailVerified'] ?? false),
      const SizedBox(height: 12),
      _infoCard(Icons.phone_outlined, 'Telefon', _user?['phone'] ?? '-', isDark),
      const SizedBox(height: 12),
      _infoCard(Icons.badge_outlined, 'Kullanıcı ID', _user?['id']?.toString() ?? '-', isDark),
    ]),
  );

  Widget _infoCard(IconData icon, String title, String value, bool isDark, {bool verified = false}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey[850] : Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isDark ? Colors.grey[700]! : AppColors.lightGreen.withOpacity(0.3)),
      boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2))],
    ),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.lightGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.lightGreen, size: 24)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
          if (verified) ...[const SizedBox(width: 8), const Icon(Icons.verified, color: AppColors.lightGreen, size: 16)],
        ]),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
      ])),
    ]),
  );
}
