import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'notification_button.dart';
import 'custom_bottom_navbar.dart';

// ============================================================================
// CONSTANTS & UTILITIES
// ============================================================================

const Color kPrimaryColor = Color(0xFF4CAF50);

const List<String> _turkishMonths = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

/// Türkçe tarih formatı (görsel)
String formatTurkishDate(DateTime d) => '${d.day} ${_turkishMonths[d.month - 1]} ${d.year}';

/// API için tarih formatı (yyyy-MM-dd)
String formatApiDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _formatDateRange(String start, String end) {
  try {
    return '${formatTurkishDate(DateTime.parse(start))} - ${formatTurkishDate(DateTime.parse(end))}';
  } catch (_) { return '$start - $end'; }
}

BoxDecoration _cardBox(BuildContext ctx) => BoxDecoration(
  color: Theme.of(ctx).brightness == Brightness.dark ? Theme.of(ctx).cardColor : Colors.white.withOpacity(0.5),
  borderRadius: BorderRadius.circular(16),
  boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2))],
);

/// Ortak silme onay dialogu
Future<bool> showTruckerDeleteDialog(BuildContext context, {required String title, required String itemName}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text('$itemName silmek istediğinizden emin misiniz?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil', style: TextStyle(color: Colors.red))),
      ],
    ),
  );
  return result ?? false;
}

// ============================================================================
// SHARED INTERNAL COMPONENTS
// ============================================================================

/// Network resim (loading/error handling dahil)
Widget _networkImage(String? url, {double size = 100, double iconSize = 40}) => ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Container(
    width: size, height: size,
    color: Colors.grey[200],
    child: url?.isNotEmpty == true
        ? Image.network(url!, fit: BoxFit.cover,
            loadingBuilder: (_, child, p) => p == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryColor)),
            errorBuilder: (_, __, ___) => Icon(Icons.local_shipping, size: iconSize, color: Colors.grey))
        : Icon(Icons.local_shipping, size: iconSize, color: Colors.grey),
  ),
);

/// Düzenle/Sil butonları
Widget _cardActions(BuildContext ctx, VoidCallback onEdit, VoidCallback onDelete) {
  final isDark = Theme.of(ctx).brightness == Brightness.dark;
  return Row(children: [
    Expanded(child: InkWell(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[200], borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Düzenle', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(ctx).textTheme.bodyLarge?.color)),
          const SizedBox(width: 6),
          Icon(Icons.edit, size: 16, color: Theme.of(ctx).iconTheme.color),
        ]),
      ),
    )),
    const SizedBox(width: 8),
    InkWell(
      onTap: onDelete,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
      ),
    ),
  ]);
}

// ============================================================================
// FORM COMPONENTS
// ============================================================================

class TruckerFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;

  const TruckerFormField({super.key, required this.controller, this.hintText, this.keyboardType, this.validator, this.suffix, this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller, keyboardType: keyboardType, validator: validator, inputFormatters: inputFormatters,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: hintText, suffixIcon: suffix, filled: true,
        hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(128)),
        fillColor: isDark ? Colors.grey[850] : Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimaryColor, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class TruckerPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;

  const TruckerPrimaryButton({super.key, required this.label, this.onPressed, this.isLoading = false, this.backgroundColor});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 56,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? kPrimaryColor, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        disabledBackgroundColor: Colors.grey[400],
      ),
      child: isLoading
          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
          : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    ),
  );
}

class TruckerSectionHeader extends StatelessWidget {
  final String title;
  const TruckerSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
  );
}

// ============================================================================
// STATE WIDGETS
// ============================================================================

class TruckerLoadingWidget extends StatelessWidget {
  final String? message;
  const TruckerLoadingWidget({super.key, this.message});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const CircularProgressIndicator(color: kPrimaryColor),
      if (message != null) ...[const SizedBox(height: 16), Text(message!, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))],
    ],
  ));
}

class TruckerErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  const TruckerErrorWidget({super.key, required this.errorMessage, this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
      const SizedBox(height: 16),
      Text('Bir Hata Oluştu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
      const SizedBox(height: 8),
      Text(errorMessage, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
      if (onRetry != null) ...[
        const SizedBox(height: 24),
        ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Tekrar Dene'),
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, foregroundColor: Colors.white)),
      ],
    ]),
  ));
}

class TruckerEmptyWidget extends StatelessWidget {
  final String title, message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  const TruckerEmptyWidget({super.key, required this.title, required this.message, this.icon = Icons.inbox_outlined, this.onAction, this.actionLabel});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 80, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(128)),
      const SizedBox(height: 24),
      Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
      const SizedBox(height: 12),
      Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color)),
      if (onAction != null && actionLabel != null) ...[
        const SizedBox(height: 32),
        ElevatedButton(onPressed: onAction, style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
          child: Text(actionLabel!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
      ],
    ]),
  ));
}

// ============================================================================
// TRUCK FORM & IMAGE UPLOAD
// ============================================================================

class TruckerTruckForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController brandModelController, plateController, capacityController;

  const TruckerTruckForm({super.key, required this.formKey, required this.brandModelController, required this.plateController, required this.capacityController});

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TruckerSectionHeader(title: 'Araç markası / modeli'),
      const SizedBox(height: 8),
      TruckerFormField(controller: brandModelController, hintText: 'Örn. Volvo FH16', validator: (v) => v?.isEmpty ?? true ? 'Lütfen araç markası/modeli giriniz' : null),
      const SizedBox(height: 20),
      TruckerSectionHeader(title: 'Plaka'),
      const SizedBox(height: 8),
      TruckerFormField(controller: plateController, hintText: 'Örn. 34ABC123',
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z]')), TextInputFormatter.withFunction((_, n) => TextEditingValue(text: n.text.toUpperCase(), selection: n.selection))],
        validator: (v) => v?.isEmpty ?? true ? 'Lütfen plaka giriniz' : null),
      const SizedBox(height: 20),
      TruckerSectionHeader(title: 'Dorse kapasitesi (ton)'),
      const SizedBox(height: 8),
      TruckerFormField(controller: capacityController, hintText: 'Örn. 25', keyboardType: TextInputType.number,
        validator: (v) {
          if (v?.isEmpty ?? true) return 'Lütfen kapasite giriniz';
          final c = double.tryParse(v!);
          return c == null ? 'Geçerli sayı giriniz' : c <= 0 ? 'Kapasite 0\'dan büyük olmalı' : null;
        }),
    ]),
  );
}

class TruckerSingleImageUploader extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback onPickImage, onRemoveImage;

  const TruckerSingleImageUploader({super.key, required this.imageBytes, required this.onPickImage, required this.onRemoveImage});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    TruckerSectionHeader(title: 'Araç Fotoğrafı'),
    const SizedBox(height: 16),
    if (imageBytes == null)
      GestureDetector(
        onTap: onPickImage,
        child: Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerColor, width: 2)),
          child: Column(children: [
            Icon(Icons.upload_file, size: 50, color: Theme.of(context).hintColor),
            const SizedBox(height: 8),
            Text('Fotoğraf Yükle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onPickImage, style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor.withAlpha(25), foregroundColor: kPrimaryColor, elevation: 0),
              child: const Text('Dosya Seç', style: TextStyle(fontWeight: FontWeight.bold))),
          ]),
        ),
      )
    else
      Stack(children: [
        Container(width: double.infinity, height: 180, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: MemoryImage(imageBytes!), fit: BoxFit.cover))),
        Positioned(top: 8, right: 8, child: GestureDetector(onTap: onRemoveImage,
          child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 18, color: Colors.white)))),
      ]),
  ]);
}

// ============================================================================
// CARD WIDGETS
// ============================================================================

class TruckerAdCard extends StatelessWidget {
  final Map<String, dynamic> ad;
  final VoidCallback onEdit, onDelete;
  const TruckerAdCard({super.key, required this.ad, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16), decoration: _cardBox(context),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(ad['truckModel'] ?? 'Araç Modeli', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
        const SizedBox(height: 6),
        Text('Plaka: ${ad['plate'] ?? ''}', style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
        if (ad['capacity'] != null) ...[
          const SizedBox(height: 4),
          Text('Kapasite: ${ad['capacity']} ton', style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
        ],
        const SizedBox(height: 4),
        Text('Fiyat: ${ad['pricePerKm']} ₺/km', style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
        const SizedBox(height: 4),
        Text(_formatDateRange(ad['startDate'] ?? '', ad['endDate'] ?? ''), style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179))),
        const SizedBox(height: 12),
        _cardActions(context, onEdit, onDelete),
      ])),
      const SizedBox(width: 16),
      _networkImage(ad['imageUrl']),
    ]),
  );
}

class TruckerTruckCard extends StatelessWidget {
  final Map<String, dynamic> truck;
  final VoidCallback onEdit, onDelete;
  const TruckerTruckCard({super.key, required this.truck, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16), decoration: _cardBox(context),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(truck['model'] ?? '', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
        const SizedBox(height: 6),
        Text(truck['plate'] ?? '', style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color)),
        if (truck['capacity'] != null) ...[
          const SizedBox(height: 4),
          Text('Kapasite: ${truck['capacity']} ton', style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
        ],
        const SizedBox(height: 12),
        _cardActions(context, onEdit, onDelete),
      ])),
      const SizedBox(width: 16),
      _networkImage(truck['image'], size: 120, iconSize: 50),
    ]),
  );
}

class TruckerJobOfferCard extends StatelessWidget {
  final Map<String, dynamic> job;
  const TruckerJobOfferCard({super.key, required this.job});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), padding: const EdgeInsets.all(20), decoration: _cardBox(context),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: kPrimaryColor.withAlpha(25), borderRadius: BorderRadius.circular(12)),
        child: Icon(job['icon'] ?? Icons.local_shipping, size: 32, color: kPrimaryColor)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(job['route'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(job['price'] ?? '', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ])),
      const Icon(Icons.arrow_forward_ios, size: 16),
    ]),
  );
}

class TruckerActionCard extends StatelessWidget {
  final String emoji, title;
  final VoidCallback onTap;
  const TruckerActionCard({super.key, required this.emoji, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(decoration: _cardBox(context),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(emoji, style: const TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
    ]),
  ));
}

// ============================================================================
// NAVIGATION & HEADER
// ============================================================================

class TruckerMainHeader extends StatelessWidget {
  final String userName;
  const TruckerMainHeader({super.key, required this.userName});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(alignment: Alignment.centerLeft, child: Text('Merhaba, $userName', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color))));
}

// ============================================================================
// DATE & AD FORM
// ============================================================================

class TruckerDateRangePicker extends StatelessWidget {
  final DateTime? startDate, endDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;
  const TruckerDateRangePicker({super.key, required this.startDate, required this.endDate, required this.onDateRangeSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () async {
        final range = await showDateRangePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
          initialDateRange: startDate != null && endDate != null ? DateTimeRange(start: startDate!, end: endDate!) : null,
          builder: (_, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: const Color(0xFF98FF98),
                onPrimary: const Color(0xFF001A00),
                primaryContainer: const Color(0xFF4CAF50),
                onPrimaryContainer: Colors.white,
                secondary: const Color(0xFF4CAF50),
                onSecondary: Colors.white,
                secondaryContainer: const Color(0xFF4CAF50),
                onSecondaryContainer: Colors.white,
                tertiary: const Color(0xFF4CAF50),
                tertiaryContainer: const Color(0xFF4CAF50),
                onTertiaryContainer: Colors.white,
                surface: Colors.grey[850]!,
                onSurface: Colors.white,
                surfaceContainerHighest: const Color(0xFF4CAF50),
              ),
            ),
            child: child!,
          ));
        if (range != null) onDateRangeSelected(range.start, range.end);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isDark ? Colors.grey[850] : Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!, width: 1.5)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(startDate == null ? 'Başlangıç ve Bitiş Tarihi Seçin' : '${formatTurkishDate(startDate!)} - ${formatTurkishDate(endDate!)}',
            style: TextStyle(color: startDate == null ? (isDark ? Colors.grey[500] : Colors.grey[600]) : Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16))),
          Icon(Icons.calendar_today, size: 20, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ]),
      ),
    );
  }
}

class TruckerAdForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<dynamic> trucks;
  final bool isLoadingTrucks;
  final String? selectedTruck;
  final DateTime? startDate, endDate;
  final TextEditingController priceController;
  final ValueChanged<String?> onTruckChanged;
  final Function(DateTime?, DateTime?) onDateRangeSelected;

  const TruckerAdForm({super.key, required this.formKey, required this.trucks, required this.isLoadingTrucks, required this.selectedTruck, required this.startDate, required this.endDate, required this.priceController, required this.onTruckChanged, required this.onDateRangeSelected});

  @override
  Widget build(BuildContext context) => Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor)),
      child: isLoadingTrucks
          ? Padding(padding: const EdgeInsets.all(16), child: Row(children: [const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryColor)), const SizedBox(width: 12), Text('Araçlar yükleniyor...', style: TextStyle(color: Theme.of(context).hintColor))]))
          : DropdownButtonHideUnderline(child: DropdownButton<String>(isExpanded: true, value: selectedTruck,
              hint: Text(trucks.isEmpty ? 'Kayıtlı araç bulunamadı' : 'Araç seç', style: TextStyle(color: Theme.of(context).hintColor)),
              items: trucks.map((t) => DropdownMenuItem<String>(value: t['id']?.toString() ?? '', child: Text('${t['model'] ?? ''} - ${t['plate'] ?? ''}'))).toList(),
              onChanged: trucks.isEmpty ? null : onTruckChanged)),
    ),
    const SizedBox(height: 20),
    TruckerDateRangePicker(startDate: startDate, endDate: endDate, onDateRangeSelected: onDateRangeSelected),
    const SizedBox(height: 20),
    TruckerFormField(controller: priceController, hintText: 'Taban fiyat ₺/km', keyboardType: TextInputType.number,
      validator: (v) {
        if (v?.isEmpty ?? true) return 'Fiyat giriniz';
        final p = double.tryParse(v!);
        return p == null ? 'Geçerli sayı giriniz' : p <= 0 ? 'Fiyat 0\'dan büyük olmalı' : null;
      }),
  ]));
}

// ============================================================================
// TRUCKER BOTTOM NAVIGATION BAR
// ============================================================================

class TruckerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final VoidCallback? onHomePressed;

  const TruckerBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onHomePressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      currentIndex: currentIndex,
      onTap: (index) => _handleNavTap(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'İş Teklifleri'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Siparişler'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
      ],
    );
  }

  void _handleNavTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    if (index == 0) {
      Navigator.popUntil(context, (r) => r.isFirst);
      if (onHomePressed != null) onHomePressed!();
    } else if (index == 1) {
      // İş Teklifleri - şimdilik snackbar
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geliştirme Aşamasında'), duration: Duration(seconds: 1)));
    } else if (index == 2) {
      // Siparişler - şimdilik snackbar
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geliştirme Aşamasında'), duration: Duration(seconds: 1)));
    } else if (index == 3) {
      // Ayarlar sayfasındayız, bir şey yapma
    }
  }
}
