import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_service.dart';
import 'geocoding_service.dart';

class DepotService {
  static Future<void> createDepot({
    required double latitude,
    required double longitude,
    required double sizeM2,
    required double capacityTon,
    required double price,
  }) async {
    final authHeaders = await TokenService.getAuthHeaders();
    final response = await http.post(
      Uri.parse(ApiConfig.createDepotUrl),
      headers: authHeaders,
      body: json.encode({
        'latitude': latitude,
        'longitude': longitude,
        'sizeM2': sizeM2,
        'capacityTon': capacityTon,
        'price': price,
      }),
    );

    await TokenService.checkAndUpdateToken(response);

    if (response.statusCode != 200) {
      final errorMessage = response.body.isNotEmpty
          ? json.decode(response.body)['error'] ?? 'Bilinmeyen hata'
          : 'Hata: ${response.statusCode}';
      throw Exception(errorMessage);
    }
  }

  static Future<void> updateDepot({
    required int depotId,
    required double price,
    required double capacityTon,
    required double sizeM2,
    double? latitude,
    double? longitude,
  }) async {
    final authHeaders = await TokenService.getAuthHeaders();

    final Map<String, dynamic> updateData = {
      'price': price,
      'capacityTon': capacityTon,
      'sizeM2': sizeM2,
    };

    if (latitude != null && longitude != null) {
      updateData['latitude'] = latitude;
      updateData['longitude'] = longitude;
    }

    final response = await http.put(
      Uri.parse(ApiConfig.updateDepotUrl(depotId)),
      headers: authHeaders,
      body: json.encode(updateData),
    );

    await TokenService.checkAndUpdateToken(response);

    if (response.statusCode != 200) {
      throw Exception('Güncelleme başarısız: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchMyDepots() async {
    final authHeaders = await TokenService.getAuthHeaders();
    final response = await http.get(Uri.parse(ApiConfig.getDepotsByOwnerUrl), headers: authHeaders);
    await TokenService.checkAndUpdateToken(response);

    if (response.statusCode != 200) throw Exception('Depolar yüklenemedi: ${response.statusCode}');

    final data = json.decode(response.body);
    final List<dynamic> rawList = data is List ? data : [data];

    // Return raw data immediately, address will be fetched by UI
    return rawList.map((depot) => Map<String, dynamic>.from(depot)).toList();
  }

  static Future<String> getAddress(double lat, double lng) async {
    return await GeocodingService.getCityAndDistrict(lat, lng);
  }
  static Future<Map<String, dynamic>> fetchDepotById(int id) async {
    final headers = await TokenService.getAuthHeaders();
    final response = await http.get(Uri.parse(ApiConfig.getDepotByIdUrl(id)), headers: headers);
    await TokenService.checkAndUpdateToken(response);
    if (response.statusCode != 200) throw Exception('Depo detayı alınamadı: ${response.statusCode}');
    return json.decode(response.body);
  }

  static Future<void> deleteDepot(int id) async {
    final headers = await TokenService.getAuthHeaders();
    final response = await http.delete(Uri.parse(ApiConfig.deleteDepotUrl(id)), headers: headers);
    await TokenService.checkAndUpdateToken(response);
    if (response.statusCode != 200) throw Exception('Depo silinemedi: ${response.statusCode}');
  }

  static Future<List<dynamic>> getAllDepots() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getAllDepotsUrl),
        headers: await TokenService.getAuthHeaders(),
      );
      await TokenService.checkAndUpdateToken(response);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes)) as List;
      }
    } catch (_) {}
    return [];
  }
}
