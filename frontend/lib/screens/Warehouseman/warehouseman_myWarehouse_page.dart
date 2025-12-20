import 'package:flutter/material.dart';
import '../../services/depot_service.dart';
import 'warehouseman_myWarehouseDetail_page.dart';
import 'warehouseman_settings_page.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/custom_bottom_navbar.dart';
import '../../utils/page_transitions.dart';

class WarehousemanMyWarehousePage extends StatefulWidget {
  const WarehousemanMyWarehousePage({super.key});
  @override
  State<WarehousemanMyWarehousePage> createState() => _WarehousemanMyWarehousePageState();
}

class _WarehousemanMyWarehousePageState extends State<WarehousemanMyWarehousePage> {
  int _idx = 0;
  List<Map<String, dynamic>> _depots = [];
  bool _isLoading = true;
  String? _err;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _isLoading = true; _err = null; });
    try {
      final depots = await DepotService.fetchMyDepots();
      if (mounted) setState(() { _depots = depots; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _err = e.toString().replaceAll('Exception: ', ''); _isLoading = false; });
    }
  }

  void _nav(int i) {
    if (i == 0) Navigator.pop(context);
    else if (i == 3) AppNavigator.push(context, const WarehousemanSettingsPage(), transition: TransitionType.slideRight);
    else setState(() => _idx = i);
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      useGradientBackground: true,
      appBar: ThemedAppBar(title: const Text('Depolarım', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), centerTitle: true, elevation: 0, backgroundColor: Colors.transparent),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))) : _err != null ? _ErrView(err: _err!, onRetry: _load) : _depots.isEmpty ? const _EmptyView() : RefreshIndicator(onRefresh: _load, child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: _depots.length, itemBuilder: (_, i) => _DepotCard(depot: _depots[i], onUpdate: _load))),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: _idx, onTap: _nav, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'), BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Siparişler'), BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Cüzdan'), BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar')]),
    );
  }
}

class _DepotCard extends StatelessWidget {
  final Map<String, dynamic> depot;
  final VoidCallback onUpdate;
  const _DepotCard({required this.depot, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await AppNavigator.push(context, WarehousemanMyWarehouseDetailPage(depotId: depot['id']), transition: TransitionType.slideRight) == true) onUpdate();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2))
            ]),
        child: Row(
          children: [
            Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.warehouse, size: 40, color: Colors.white)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(
                    child: FutureBuilder<String>(
                      future: (depot['latitude'] != null && depot['longitude'] != null) 
                          ? DepotService.getAddress(depot['latitude'], depot['longitude']) 
                          : Future.value('Konum bilgisi yok'),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'Adres yükleniyor...',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                          maxLines: 2, overflow: TextOverflow.ellipsis
                        );
                      }
                    ),
                  ),
                  const Text('0%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                ]),
                const SizedBox(height: 8),
                Text('Kapasite: ${depot['capacityTon']} ton', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                Text('Alan: ${depot['sizeM2']} m²', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                Text('Fiyat: ${depot['price']} ₺', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 12),
                ClipRRect(borderRadius: BorderRadius.circular(10), child: const LinearProgressIndicator(value: 0, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)), minHeight: 8)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrView extends StatelessWidget {
  final String err; final VoidCallback onRetry;
  const _ErrView({required this.err, required this.onRetry});
  @override Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error_outline, size: 64, color: Colors.grey[400]), const SizedBox(height: 16), Text(err, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 16)), const SizedBox(height: 16), ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Tekrar Dene'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)))]));
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.warehouse_outlined, size: 64, color: Colors.grey[400]), const SizedBox(height: 16), Text('Henüz depo eklemediniz', style: TextStyle(color: Colors.grey[600], fontSize: 16))]));
}
