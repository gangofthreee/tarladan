import 'package:flutter/material.dart';
import '../../config/api_config.dart';

class TruckAdCard extends StatelessWidget {
  final Map<String, dynamic> truck;
  final bool isSelected;
  final VoidCallback onTap;

  const TruckAdCard({
    super.key,
    required this.truck,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine background color based on selection and theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white.withOpacity(0.7);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Truck Image/Icon
            _buildTruckImage(context, truck['imageUrl'], truck['icon'], isSelected),
            const SizedBox(width: 16),
            // Infos
            Expanded(child: _buildTruckInfo(context)),
            const SizedBox(width: 8),
            // Select Button Label
            _buildSelectLabel(),
          ],
        ),
      ),
    );
  }

  Widget _buildTruckImage(BuildContext context, String? imageUrl, String icon, bool isSelected) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor = isSelected 
        ? const Color(0xFF4CAF50).withOpacity(0.1) 
        : (isDarkMode ? Colors.grey[800] : Colors.grey[200]);

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: placeholderColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: imageUrl != null && imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '${ApiConfig.baseUrl}$imageUrl',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Text(icon, style: const TextStyle(fontSize: 40)),
                ),
              )
            : Text(icon, style: const TextStyle(fontSize: 40)),
      ),
    );
  }

  Widget _buildTruckInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sürücü: ${truck['truckerName']}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        _infoText(context, 'Araç: ${truck['vehicle']}', 0.9),
        const SizedBox(height: 4),
        _infoText(context, 'Plaka: ${truck['plate']}', 0.9),
        const SizedBox(height: 4),
        _infoText(context, 'Kapasite: ${truck['capacity']} ton', 0.7),
        const SizedBox(height: 4),
        Text(
          'Fiyat: ${truck['basePrice']} ${truck['priceUnit']}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 4),
        _infoText(context, 'Müsaitlik: ${truck['availability']}', 0.6),
      ],
    );
  }

  Widget _infoText(BuildContext context, String text, double opacity) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(opacity),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSelectLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Seç',
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF4CAF50),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class SelectedTruckBottomBar extends StatelessWidget {
  final Map<String, dynamic> truck;
  final VoidCallback onConfirm;

  const SelectedTruckBottomBar({
    super.key,
    required this.truck,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTruckThumbnail(truck),
          const SizedBox(width: 16),
          Expanded(child: _buildSelectedInfo(context, truck)),
          const SizedBox(width: 12),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildTruckThumbnail(Map<String, dynamic> truck) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: truck['imageUrl'] != null && truck['imageUrl'].isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '${ApiConfig.baseUrl}${truck['imageUrl']}',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Text(truck['icon'], style: const TextStyle(fontSize: 40)),
                ),
              )
            : Text(truck['icon'], style: const TextStyle(fontSize: 40)),
      ),
    );
  }

  Widget _buildSelectedInfo(BuildContext context, Map<String, dynamic> truck) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sürücü: ${truck['truckerName']}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Text('Araç: ${truck['vehicle']}', style: TextStyle(fontSize: 13, color: Colors.grey[600]), maxLines: 1),
        Text('Plaka: ${truck['plate']}', style: TextStyle(fontSize: 13, color: Colors.grey[600]), maxLines: 1),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: onConfirm,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Row(
        children: [
          Text('Onayla', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 20),
        ],
      ),
    );
  }
}
