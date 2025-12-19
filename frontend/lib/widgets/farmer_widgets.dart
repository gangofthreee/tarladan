import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../screens/Farmer/farmer_all_ads.dart';
import '../screens/Farmer/farmer_orders.dart';
import '../screens/Farmer/farmer_settings_page.dart';

/// Farmer için ortak kullanılan sabitler
class FarmerConstants {
  FarmerConstants._();

  /// Farmer teması için ana renk
  static const Color primaryColor = Color(0xFF00D563);

  /// Bottom navigation bar item'ları
  static const List<BottomNavigationBarItem> bottomNavItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
    BottomNavigationBarItem(icon: Icon(Icons.format_list_bulleted), label: 'İlanlarım'),
    BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Siparişler'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
  ];

  /// Resim yolunu işle: /app/uploads/ → /uploads/ dönüşümü
  static String processImagePath(String path, String baseUrl) {
    String p = path;
    if (p.startsWith('/app/uploads/')) p = p.replaceFirst('/app/uploads/', '/uploads/');
    return '$baseUrl$p';
  }
}

/// Farmer sayfaları için ortak bottom navigation bar
class FarmerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final VoidCallback? onHomePressed;

  const FarmerBottomNavBar({super.key, required this.currentIndex, this.onHomePressed});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
    child: BottomNavigationBar(currentIndex: currentIndex, type: BottomNavigationBarType.fixed, selectedItemColor: FarmerConstants.primaryColor, unselectedItemColor: Colors.grey, elevation: 0, backgroundColor: Theme.of(context).cardColor, items: FarmerConstants.bottomNavItems, onTap: (i) => _handleNavTap(context, i)),
  );

  void _handleNavTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    final pages = [null, const FarmerAllAds(), const FarmerOrdersScreen(), const FarmerSettingsPage()];
    if (index == 0) {
      // Anasayfaya dön - popUntil ile ana sayfaya git
      Navigator.popUntil(context, (r) => r.isFirst);
      // Callback varsa çağır (örn: refresh için)
      if (onHomePressed != null) onHomePressed!();
    } else {
      final page = pages[index];
      if (page != null) {
        currentIndex == 0 
            ? Navigator.push(context, MaterialPageRoute(builder: (_) => page)) 
            : Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
      }
    }
  }
}

/// Farmer için ürün kartı widget'ı (Ana sayfa için basit versiyon)
class FarmerProductItemCard extends StatelessWidget {
  final String name, amount, price, status;
  final String? ownerName;
  final bool isActive;
  final VoidCallback? onTap;

  const FarmerProductItemCard({
    super.key,
    required this.name,
    required this.amount,
    required this.price,
    required this.status,
    this.ownerName,
    this.isActive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            if (ownerName != null && ownerName!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(ownerName!, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
            ],
            const SizedBox(height: 4),
            Text(amount, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ]),
          Row(children: [
            Text(price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(width: 12),
            _StatusBadge(status: status, isActive: isActive),
          ]),
        ]),
      ),
    );
  }
}

/// Farmer için ürün detay kartı (İlanlarım sayfası için detaylı versiyon)
class FarmerProductDetailCard extends StatelessWidget {
  final String name;
  final double quantityKg, pricePerKg, minBuy;
  final String? imagePath;
  final String baseUrl;
  final VoidCallback? onTap;

  const FarmerProductDetailCard({
    super.key,
    required this.name,
    required this.quantityKg,
    required this.pricePerKg,
    required this.minBuy,
    this.imagePath,
    required this.baseUrl,
    this.onTap,
  });

  String get _imageUrl => imagePath == null ? '' : FarmerConstants.processImagePath(imagePath!, baseUrl);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            _buildImage(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  _text('Miktar: ${quantityKg.toStringAsFixed(0)} kg'),
                  const SizedBox(height: 4),
                  _text('Fiyat: ${pricePerKg.toStringAsFixed(2)} ₺/kg'),
                  const SizedBox(height: 4),
                  _text('Min. Alım: ${minBuy.toStringAsFixed(0)} kg', color: Colors.grey[500]),
                ],
              ),
            ),
            const _StatusBadge(status: 'Aktif', isActive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: FarmerConstants.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: imagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2, size: 40, color: Colors.grey),
              ),
            )
          : const Icon(Icons.inventory_2, size: 40, color: Colors.grey),
    );
  }

  Widget _text(String text, {Color? color}) => Text(
        text,
        style: TextStyle(fontSize: 14, color: color ?? Colors.grey[600]),
      );
}

/// Farmer için sipariş kartı
class FarmerOrderCard extends StatelessWidget {
  final String productName, buyer, status, date;
  final String? depotName, imagePath, baseUrl;
  final int? quantityKg;

  const FarmerOrderCard({
    super.key,
    required this.productName,
    required this.buyer,
    required this.status,
    required this.date,
    this.depotName,
    this.quantityKg,
    this.imagePath,
    this.baseUrl,
  });

  static const _statusMap = {
    'PENDING': ('Beklemede', Color(0xFFFFECB3), Color(0xFFFF8F00), Icons.schedule),
    'CONFIRMED': ('Onaylandı', Color(0xFFB3E5FC), Color(0xFF0277BD), Icons.check_circle_outline),
    'SHIPPED': ('Kargoda', Color(0xFFE1BEE7), Color(0xFF7B1FA2), Icons.local_shipping_outlined),
    'DELIVERED': ('Teslim Edildi', Color(0xFFC8E6C9), Color(0xFF2E7D32), Icons.done_all),
    'CANCELLED': ('İptal', Color(0xFFFFCDD2), Color(0xFFC62828), Icons.cancel_outlined),
  };

  (String, Color, Color, IconData) get _statusInfo => 
      _statusMap[status.toUpperCase()] ?? (status, const Color(0xFFE0E0E0), const Color(0xFF616161), Icons.info_outline);

  String? get _imageUrl => 
      (imagePath == null || baseUrl == null) ? null : FarmerConstants.processImagePath(imagePath!, baseUrl!);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final (label, bgColor, txtColor, icon) = _statusInfo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_imageUrl != null)
            Container(
              width: 70,
              height: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: dark ? Colors.grey[800] : Colors.grey[200],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                _imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.image, size: 30, color: Colors.grey[400]),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Alıcı', buyer, textColor),
                if (depotName?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  _buildInfoRow('Depo', depotName!, textColor),
                ],
                if (quantityKg != null) ...[
                  const SizedBox(height: 4),
                  _buildInfoRow('Miktar', '$quantityKg kg', textColor),
                ],
                const SizedBox(height: 8),
                _buildStatusBadge(label, bgColor, txtColor, icon),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color? color) => Row(
        children: [
          Text('$label: ', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  Widget _buildStatusBadge(String label, Color bgColor, Color txtColor, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: txtColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: txtColor),
            ),
          ],
        ),
      );
}

/// Farmer için aksiyon kartı (Ana sayfadaki grid kartları)
class FarmerActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const FarmerActionCard({super.key, required this.title, required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? FarmerConstants.primaryColor;
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: c.withOpacity(0.3),
        highlightColor: c.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 48, color: c),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color), textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}

/// Farmer için tab selector widget'ı (Aktif/Geçmiş toggle)
class FarmerTabSelector extends StatelessWidget {
  final bool isFirstTabSelected;
  final String firstTabLabel, secondTabLabel;
  final ValueChanged<bool> onTabChanged;

  const FarmerTabSelector({super.key, required this.isFirstTabSelected, required this.firstTabLabel, required this.secondTabLabel, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = dark ? Colors.grey[800] : const Color(0xFFE8E8E8);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    Widget tab(String label, bool sel, VoidCallback onTap) => Expanded(child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: sel ? FarmerConstants.primaryColor : inactiveColor, borderRadius: BorderRadius.circular(24)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: sel ? Colors.white : textColor?.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    ));

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [tab(firstTabLabel, isFirstTabSelected, () => onTabChanged(true)), const SizedBox(width: 8), tab(secondTabLabel, !isFirstTabSelected, () => onTabChanged(false))]),
    );
  }
}

/// Farmer için boş liste widget'ı
class FarmerEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const FarmerEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.onActionPressed,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (onActionPressed != null && actionLabel != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onActionPressed,
              icon: const Icon(Icons.refresh),
              label: Text(actionLabel!),
              style: ElevatedButton.styleFrom(
                backgroundColor: FarmerConstants.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Farmer için hata widget'ı
class FarmerErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const FarmerErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
            style: ElevatedButton.styleFrom(
              backgroundColor: FarmerConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Durum rozeti (internal widget)
class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isActive;

  const _StatusBadge({
    required this.status,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? FarmerConstants.primaryColor : const Color(0xFFFF9500),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================================
// FARMER AD DETAIL WIDGETS
// ============================================================

/// Farmer için düzenlenebilir bilgi alanı (edit mode'da TextFormField, değilse Text)
class FarmerEditableField extends StatelessWidget {
  final String label;
  final String value;
  final TextEditingController controller;
  final bool isEditMode;
  final String suffix;
  final bool isNumeric;
  final String? Function(String?)? validator;

  const FarmerEditableField({
    super.key,
    required this.label,
    required this.value,
    required this.controller,
    required this.isEditMode,
    this.suffix = '',
    this.isNumeric = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        isEditMode
            ? TextFormField(
                controller: controller,
                keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
                decoration: InputDecoration(
                  suffixText: suffix.isNotEmpty ? suffix.trim() : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: validator ?? _defaultValidator,
              )
            : Text(
                '$value$suffix',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
      ],
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bu alan boş bırakılamaz';
    }
    if (isNumeric && double.tryParse(value) == null) {
      return 'Geçerli bir sayı girin';
    }
    return null;
  }
}

/// Farmer için ürün detay butonları (Düzenle/Sil veya Kaydet)
class FarmerDetailButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isSaving;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  const FarmerDetailButtons({
    super.key,
    required this.isEditMode,
    required this.isSaving,
    required this.onEdit,
    required this.onSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditMode) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isSaving ? null : onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: FarmerConstants.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Değişiklikleri Kaydet',
                  style: TextStyle(fontSize: 16),
                ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            label: const Text('Düzenle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: FarmerConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('İlanı Kaldır'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Farmer için silme onay dialogu
class FarmerDeleteDialog extends StatelessWidget {
  final String productName;
  final VoidCallback onConfirm;

  const FarmerDeleteDialog({
    super.key,
    required this.productName,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required String productName,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => FarmerDeleteDialog(
        productName: productName,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('İlanı Sil'),
      content: Text(
        '$productName ürününü silmek istediğinizden emin misiniz?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Sil'),
        ),
      ],
    );
  }
}

/// Konum yok placeholder widget'ı
class FarmerNoLocationPlaceholder extends StatelessWidget {
  const FarmerNoLocationPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 60,
              color: Colors.grey[500],
            ),
            const SizedBox(height: 8),
            Text(
              'Konum bilgisi yok',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Farmer ürün resmi gösterme widget'ı
class FarmerProductImageSection extends StatelessWidget {
  final String? imagePath;
  final String baseUrl;
  final Widget? selectedImageWidget;
  final bool isEditMode;
  final VoidCallback? onTap;
  final double height;

  const FarmerProductImageSection({
    super.key,
    this.imagePath,
    required this.baseUrl,
    this.selectedImageWidget,
    this.isEditMode = false,
    this.onTap,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: isEditMode ? onTap : null,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : const Color(0xFFFFE8D6),
            ),
            child: _buildContent(),
          ),
          if (isEditMode)
            Positioned(
              bottom: 16,
              right: 16,
              child: CircleAvatar(
                backgroundColor: FarmerConstants.primaryColor,
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (selectedImageWidget != null) return selectedImageWidget!;
    if (imagePath != null && imagePath!.isNotEmpty) return _buildNetworkImage();
    
    return Center(
      child: Icon(Icons.image, size: 80, color: Colors.grey[400]),
    );
  }

  Widget _buildNetworkImage() {
    return Image.network(
      FarmerConstants.processImagePath(imagePath!, baseUrl),
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            color: FarmerConstants.primaryColor,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 8),
            Text('Fotoğraf yüklenemedi', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

/// Farmer depo haritası widget'ı
class FarmerDepotMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? address;
  final double height;

  const FarmerDepotMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.address,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (address != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(child: Text(address!, style: TextStyle(color: Colors.grey[700], fontSize: 14))),
            ]),
          ),
        Container(
          height: height,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(latitude, longitude),
              initialZoom: 15.0,
              interactionOptions: InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
            ),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.gangofthree.tarladan'),
              MarkerLayer(markers: [
                Marker(point: LatLng(latitude, longitude), width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.red, size: 40)),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

/// Farmer bölüm başlığı widget'ı
class FarmerSectionTitle extends StatelessWidget {
  final String title;
  final double fontSize;

  const FarmerSectionTitle({
    super.key,
    required this.title,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }
}
