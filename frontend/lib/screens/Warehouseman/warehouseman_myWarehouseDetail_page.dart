import 'package:flutter/material.dart';
import '../../services/depot_service.dart';
import 'warehouseman_updateWarehouseInfo_page.dart';
import '../../widgets/themed_scaffold.dart';

class WarehousemanMyWarehouseDetailPage extends StatefulWidget {
  final int depotId;
  const WarehousemanMyWarehouseDetailPage({super.key, required this.depotId});

  @override
  State<WarehousemanMyWarehouseDetailPage> createState() => _State();
}

class _State extends State<WarehousemanMyWarehouseDetailPage> {
  Map<String, dynamic>? _depot;
  bool _loading = true;
  String? _addr;
  bool _updated = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = await DepotService.fetchDepotById(widget.depotId);
      if (mounted) setState(() => _depot = d);
      if (d['latitude'] != null) {
        final a = await DepotService.getAddress(d['latitude'], d['longitude']);
        if (mounted) setState(() => _addr = a);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _del() async {
    try {
      await DepotService.deleteDepot(widget.depotId);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silindi'))); Navigator.pop(context, true); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      useGradientBackground: true,
      appBar: ThemedAppBar(
        title: const Text('Depo Detayı', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context, _updated)),
        centerTitle: true, elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _depot == null
          ? Center(child: ElevatedButton(onPressed: _load, child: const Text('Tekrar Dene')))
          : SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
              _card('Depo Bilgileri', [
                _row(Icons.location_on, 'Adres', _addr ?? 'Yükleniyor...'),
                _row(Icons.warehouse, 'Kapasite', '${_depot!['capacityTon']} ton'),
                _row(Icons.attach_money, 'Fiyat', '${_depot!['price']} ₺'),
              ]),
              const SizedBox(height: 12),
              _card('Mevcut Doluluk', [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Kapasite: ${_depot!['capacityTon']} ton', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Alan: ${_depot!['sizeM2']} m²', style: TextStyle(fontSize: 16, color: Colors.grey[600]))
                ]),
                const SizedBox(height: 12),
                Text('Fiyat: ${_depot!['price']} ₺', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ]),
              const SizedBox(height: 30),
              Row(children: [
                Expanded(child: SizedBox(height: 50, child: ElevatedButton(
                  onPressed: () async {
                    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => WarehousemanUpdateWarehouseInfoPage(
                      depotId: widget.depotId, warehouseName: 'Depo #${widget.depotId}',
                      currentLatitude: _depot!['latitude'], currentLongitude: _depot!['longitude'],
                      currentSize: '${_depot!['sizeM2']}', currentCapacity: '${_depot!['capacityTon']}', currentPrice: '${_depot!['price']}'
                    )));
                    if (res == true) { _updated = true; _load(); }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Düzenle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                ))),
                const SizedBox(width: 12),
                Expanded(child: SizedBox(height: 50, child: ElevatedButton(
                  onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Sil'), content: const Text('Emin misiniz?'), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('İptal')), ElevatedButton(onPressed: (){Navigator.pop(context); _del();}, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Sil'))])),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE57373), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Sil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                ))),
              ]),
            ])),
    );
  }

  Widget _card(String title, List<Widget> children) => Container(
    width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).cardColor
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 20), ...children]),
  );

  Widget _row(IconData icon, String title, String sub) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF4CAF50), size: 28)),
    const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text(sub, style: TextStyle(fontSize: 14, color: Colors.grey[600]))]))
  ]));
}
