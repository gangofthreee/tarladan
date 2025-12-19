import 'package:flutter/material.dart';
import 'trucker_truckUpdate_page.dart';
import 'trucker_truckSaving_page.dart';
import '../../services/truck_service.dart';
import '../../widgets/themed_scaffold.dart';
import '../../widgets/trucker_widgets.dart';

class TruckerTruckListPage extends StatefulWidget {
  const TruckerTruckListPage({super.key});
  @override
  State<TruckerTruckListPage> createState() => _TruckerTruckListPageState();
}

class _TruckerTruckListPageState extends State<TruckerTruckListPage> {
  List<Map<String, dynamic>> trucks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() { super.initState(); _loadTrucks(); }

  Future<void> _loadTrucks() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      trucks = await TruckService.getTrucksByTrucker();
      trucks.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
    } catch (e) { _errorMessage = e.toString(); }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleDelete(Map<String, dynamic> truck) async {
    try {
      await TruckService.deleteTruck(truck['id']);
      setState(() => trucks.remove(truck));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Araç silindi')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> truck) async {
    if (await showTruckerDeleteDialog(context, title: 'Aracı Sil', itemName: truck['model'])) _handleDelete(truck);
  }

  Future<void> _navigateAndRefresh(Widget page) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (result == true) _loadTrucks();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: ThemedAppBar(title: const Text('Araçlarım'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
      body: _isLoading
          ? const TruckerLoadingWidget(message: 'Araçlar yükleniyor...')
          : _errorMessage != null
              ? TruckerErrorWidget(errorMessage: _errorMessage!, onRetry: _loadTrucks)
              : trucks.isEmpty
                  ? const TruckerEmptyWidget(title: 'Henüz Kayıtlı Araç Yok', message: 'Araç ekleyerek başlayabilirsiniz', icon: Icons.local_shipping_outlined)
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: trucks.length,
                      itemBuilder: (_, i) => TruckerTruckCard(
                        truck: trucks[i],
                        onEdit: () => _navigateAndRefresh(TruckerTruckUpdatePage(truck: trucks[i])),
                        onDelete: () => _confirmDelete(trucks[i]),
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndRefresh(const TruckerTruckSavingPage()),
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Araç Ekle'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
