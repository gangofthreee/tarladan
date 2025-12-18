import 'package:http/http.dart' as http;
import 'dart:convert';

class GeocodingService {
  // OpenStreetMap Nominatim API (ücretsiz)
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static final Map<String, String> _cache = {};

  /// Önbelleği temizler (Örn: Çıkış yaparken kullanılabilir)
  static void clearCache() {
    _cache.clear();
  }

  /// Reverse Geocoding: Koordinatları adrese çevirir
  ///
  /// [latitude] ve [longitude] parametreleri ile konum bilgisini alır
  /// ve Nominatim API'si kullanarak insan okunabilir adres döndürür.
  ///
  /// Örnek dönüş: "Çankaya, Ankara, Turkey"
  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        '$_nominatimBaseUrl/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent':
              'Tarladan Mobile App', // Nominatim user-agent gerektirir
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['display_name'] != null) {
          return data['display_name'];
        }

        // Alternatif olarak adres parçalarını birleştir
        if (data['address'] != null) {
          final address = data['address'];
          List<String> parts = [];

          if (address['road'] != null) parts.add(address['road']);
          if (address['suburb'] != null) parts.add(address['suburb']);
          if (address['city'] != null) parts.add(address['city']);
          if (address['state'] != null) parts.add(address['state']);
          if (address['country'] != null) parts.add(address['country']);

          if (parts.isNotEmpty) {
            return parts.join(', ');
          }
        }

        return 'Adres bulunamadı';
      } else {
        print('Geocoding hatası: ${response.statusCode}');
        return 'Koordinatlar: $latitude, $longitude';
      }
    } catch (e) {
      print('Geocoding exception: $e');
      return 'Koordinatlar: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    }
  }

  /// Sadece İl ve İlçe bilgisini döndürür
  ///
  /// Örnek dönüş: "Menteşe, Muğla"
  static Future<String> getCityAndDistrict(
    double latitude,
    double longitude,
  ) async {
    final key = '$latitude,$longitude';
    if (_cache.containsKey(key)) return _cache[key]!;

    try {
      final url = Uri.parse(
        '$_nominatimBaseUrl/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'Tarladan Mobile App'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['address'] != null) {
          final address = data['address'];

          // İlçe bilgisi (county, town, municipality, district)
          String? district =
              address['county'] ??
              address['town'] ??
              address['municipality'] ??
              address['district'];

          // İl bilgisi (city, state, province)
          String? city =
              address['city'] ?? address['state'] ?? address['province'];

          String result = 'Konum bilgisi yok';
          if (district != null && city != null) {
            result = '$district, $city';
          } else if (city != null) {
            result = city;
          } else if (district != null) {
            result = district;
          }
          
          if (result != 'Konum bilgisi yok') {
             _cache[key] = result;
          }
          return result;
        }

        return 'Konum bilgisi yok';
      } else {
        return 'Konum bilgisi yok';
      }
    } catch (e) {
      print('City/District geocoding exception: $e');
      return 'Konum bilgisi yok';
    }
  }

  /// İleride gerekirse: Forward Geocoding (Adres -> Koordinat)
  static Future<Map<String, double>?> getCoordinatesFromAddress(
    String address,
  ) async {
    try {
      final url = Uri.parse(
        '$_nominatimBaseUrl/search?format=json&q=${Uri.encodeComponent(address)}',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'Tarladan Mobile App'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          final result = data[0];
          return {
            'latitude': double.parse(result['lat']),
            'longitude': double.parse(result['lon']),
          };
        }
      }

      return null;
    } catch (e) {
      print('Forward geocoding exception: $e');
      return null;
    }
  }
}
