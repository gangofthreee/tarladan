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
  void initState() {
    super.initState();
    _loadTruck();
  }

  Future<void> _loadTruck() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      trucks = await TruckService.getTrucksByTrucker();
    } catch (e) {
      _errorMessage = e.toString();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _handleDelete(Map<String, dynamic> truck) async {
    try {
      await TruckService.deleteTruck(truck['id']);
      setState(() => trucks.remove(truck));
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Araç silindi')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> truck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aracı Sil'),
        content: Text(
          '${truck['model']} aracını silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDelete(truck);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: ThemedAppBar(
        title: const Text('Araçlarım'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const TruckerLoadingWidget(message: 'Araçlar yükleniyor...')
          : _errorMessage != null
          ? TruckerErrorWidget(
              errorMessage: _errorMessage!,
              onRetry: _loadTruck,
            )
          : trucks.isEmpty
          ? const TruckerEmptyWidget(
              title: 'Henüz Kayıtlı Araç Yok',
              message: 'Araç ekleyerek başlayabilirsiniz',
              icon: Icons.local_shipping_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: trucks.length,
              itemBuilder: (context, index) {
                final truck = trucks[index];
                return TruckerTruckCard(
                  truck: truck,
                  onEdit: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TruckerTruckUpdatePage(truck: truck),
                      ),
                    );
                    if (result == true) _loadTruck();
                  },
                  onDelete: () => _showDeleteConfirmation(truck),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TruckerTruckSavingPage(),
            ),
          );
          if (result == true) _loadTruck();
        },
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Araç Ekle'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
