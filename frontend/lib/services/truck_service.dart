import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import 'token_service.dart';

/// Genel image işlemleri servisi - tüm user türleri için kullanılabilir
class ImageService {
  static Future<Uint8List> compressImage(
    Uint8List imageBytes, {
    int maxSize = 1200,
    int quality = 85,
  }) async {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    if (image.width > maxSize || image.height > maxSize) {
      image = img.copyResize(
        image,
        width: image.width > image.height ? maxSize : null,
        height: image.height >= image.width ? maxSize : null,
      );
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }

  static String normalizeImageExtension(String filename) {
    return filename.replaceAll(RegExp(r'\.(png|PNG|heic|HEIC)$'), '.jpg');
  }
}

/// Vehicle (Araç) işlemleri servisi - Trucker, Farmer vb. için kullanılabilir
class VehicleService {
  static Future<http.Response> createVehicle({
    required String endpoint,
    required Map<String, String> fields,
    required XFile photoFile,
    required Uint8List photoBytes,
    String photoFieldName = 'photo',
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(endpoint));

    final authHeaders = await TokenService.getAuthHeadersForMultipart();
    request.headers.addAll(authHeaders);

    request.fields.addAll(fields);

    request.files.add(
      http.MultipartFile.fromBytes(
        photoFieldName,
        photoBytes,
        filename: ImageService.normalizeImageExtension(photoFile.name),
      ),
    );

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    await TokenService.checkAndUpdateToken(response);

    return response;
  }

  static Future<http.Response> updateVehicle({
    required String endpoint,
    required Map<String, String> fields,
    XFile? photoFile,
    Uint8List? photoBytes,
    String photoFieldName = 'photo',
  }) async {
    var request = http.MultipartRequest('PATCH', Uri.parse(endpoint));

    final authHeaders = await TokenService.getAuthHeadersForMultipart();
    request.headers.addAll(authHeaders);

    request.fields.addAll(fields);

    if (photoFile != null && photoBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          photoFieldName,
          photoBytes,
          filename: ImageService.normalizeImageExtension(photoFile.name),
        ),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    await TokenService.checkAndUpdateToken(response);

    return response;
  }
}

/// Trucker özel metodları - yukarıdaki genel servisleri kullanır
class TruckService {
  // Truck CRUD işlemleri
  static Future<http.Response> createTruck({
    required String vehicle,
    required String capacityTon,
    required String plate,
    required String basePrice,
    required XFile photoFile,
    required Uint8List photoBytes,
  }) async {
    return VehicleService.createVehicle(
      endpoint: ApiConfig.createTruckUrl,
      fields: {
        'vehicle': vehicle,
        'capacityTon': capacityTon,
        'plate': plate,
        'basePrice': basePrice,
      },
      photoFile: photoFile,
      photoBytes: photoBytes,
    );
  }

  static Future<http.Response> updateTruck({
    required int truckId,
    required String vehicle,
    required String capacityTon,
    required String plate,
    required String basePrice,
    XFile? photoFile,
    Uint8List? photoBytes,
  }) async {
    return VehicleService.updateVehicle(
      endpoint: ApiConfig.updateTruckUrl(truckId),
      fields: {
        'vehicle': vehicle,
        'capacityTon': capacityTon,
        'plate': plate,
        'basePrice': basePrice,
      },
      photoFile: photoFile,
      photoBytes: photoBytes,
    );
  }

  /// Trucker'a ait tüm truck'ları getir
  static Future<List<Map<String, dynamic>>> getTrucksByTrucker() async {
    final authHeaders = await TokenService.getAuthHeaders();
    final response = await http.get(
      Uri.parse(ApiConfig.getTrucksByTruckerUrl),
      headers: authHeaders,
    );

    await TokenService.checkAndUpdateToken(response);

    if (response.statusCode == 200) {
      final List<dynamic> dataList = json.decode(response.body);
      print('🚛 Truck Response: $dataList');
      return dataList.map((data) {
        print('🖼️ ImageUrl from backend: ${data['imageUrl']}');
        final fullImageUrl = data['imageUrl'] != null
            ? '${ApiConfig.baseUrl}${data['imageUrl']}'
            : 'https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?w=400';
        print('🌐 Full Image URL: $fullImageUrl');
        return {
          'id': data['id'],
          'model': data['vehicle'] ?? 'Araç Modeli',
          'plate': data['plate_number'] ?? 'Plaka',
          'capacity': data['capacityTon'],
          'price': data['basePrice'],
          'image': fullImageUrl,
        };
      }).toList();
    } else {
      throw Exception('Araç bilgileri yüklenemedi: ${response.statusCode}');
    }
  }

  /// Truck silme işlemi
  static Future<void> deleteTruck(int truckId) async {
    final authHeaders = await TokenService.getAuthHeaders();
    final response = await http.delete(
      Uri.parse(ApiConfig.deleteTruckUrl(truckId)),
      headers: authHeaders,
    );

    await TokenService.checkAndUpdateToken(response);

    if (response.statusCode != 200) {
      throw Exception('Araç silinemedi: ${response.statusCode}');
    }
  }

  /// Truck ad (ilan) işlemleri
  static Future<http.Response> createTruckAd({
    required int truckId,
    required String startDate,
    required String endDate,
    required double pricePerKm,
  }) async {
    final authHeaders = await TokenService.getAuthHeaders();
    final response = await http.post(
      Uri.parse(ApiConfig.createTruckAdUrl),
      headers: authHeaders,
      body: json.encode({
        'truckId': truckId,
        'startDate': startDate,
        'endDate': endDate,
        'pricePerKm': pricePerKm,
      }),
    );

    await TokenService.checkAndUpdateToken(response);
    return response;
  }

  static Future<http.Response> updateTruckAd({
    required int adId,
    required int truckId,
    required String startDate,
    required String endDate,
    required double pricePerKm,
  }) async {
    final authHeaders = await TokenService.getAuthHeaders();
    final response = await http.patch(
      Uri.parse(ApiConfig.updateTruckAdUrl(adId)),
      headers: authHeaders,
      body: json.encode({
        'truckId': truckId,
        'startDate': startDate,
        'endDate': endDate,
        'pricePerKm': pricePerKm,
      }),
    );

    await TokenService.checkAndUpdateToken(response);
    return response;
  }

  static Future<List<Map<String, dynamic>>> getTruckAdsByTrucker() async {
    final authHeaders = await TokenService.getAuthHeaders();
    final response = await http.get(
      Uri.parse(ApiConfig.getTruckAdsByTruckerUrl),
      headers: authHeaders,
    );

    await TokenService.checkAndUpdateToken(response);

    if (response.statusCode == 200) {
      final List<dynamic> dataList = json.decode(response.body);
      return dataList.map((data) => data as Map<String, dynamic>).toList();
    } else {
      throw Exception('İlanlar yüklenemedi: ${response.statusCode}');
    }
  }

  static Future<void> deleteTruckAd(int adId) async {
    final authHeaders = await TokenService.getAuthHeaders();
    final response = await http.delete(
      Uri.parse(ApiConfig.deleteTruckAdUrl(adId)),
      headers: authHeaders,
    );

    await TokenService.checkAndUpdateToken(response);

    if (response.statusCode != 200) {
      throw Exception('İlan silinemedi: ${response.statusCode}');
    }
  }
}
