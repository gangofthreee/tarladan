import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../config/api_config.dart';
import 'token_service.dart';

/// Farmer ürün API servisi
class FarmerProductService {
  static Future<Map<String, dynamic>?> fetchProduct(int productId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getProductDetailUrl(productId)),
        headers: await TokenService.getAuthHeaders(),
      );
      await TokenService.checkAndUpdateToken(response);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}
    return null;
  }

  static Future<(bool, String?)> updateProduct(int productId, Map<String, String> fields, XFile? image) async {
    try {
      var request = http.MultipartRequest('PATCH', Uri.parse(ApiConfig.updateProductUrl(productId)));
      request.headers.addAll(await TokenService.getAuthHeadersForMultipart());
      request.fields.addAll(fields);
      if (image != null) {
        request.files.add(kIsWeb
            ? http.MultipartFile.fromBytes('photo', await image.readAsBytes(), filename: image.name)
            : await http.MultipartFile.fromPath('photo', image.path));
      }
      final response = await http.Response.fromStream(await request.send());
      await TokenService.checkAndUpdateToken(response);
      
      if (response.statusCode == 200) return (true, null);
      return (false, _parseError(response));
    } catch (e) {
      return (false, 'Hata: $e');
    }
  }

  static Future<(bool, String?)> deleteProduct(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.deleteProductUrl(productId)),
        headers: await TokenService.getAuthHeaders(),
      );
      await TokenService.checkAndUpdateToken(response);
      
      if (response.statusCode == 200) return (true, null);
      return (false, _parseError(response));
    } catch (e) {
      return (false, 'Hata: $e');
    }
  }

  static Future<List<dynamic>?> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getAllProductsUrl),
        headers: await TokenService.getAuthHeaders(),
      );
      await TokenService.checkAndUpdateToken(response);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes)) as List;
      }
    } catch (_) {}
    return null;
  }

  static Future<List<dynamic>?> getMyProducts() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getFarmerProductsUrl),
        headers: await TokenService.getAuthHeaders(),
      );
      await TokenService.checkAndUpdateToken(response);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data is List ? data : [data];
      }
    } catch (_) {}
    return null;
  }

  static Future<(bool, String?, int?)> createProduct(Map<String, String> fields, XFile image, int depotId) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(ApiConfig.createProductUrl));
      request.headers.addAll(await TokenService.getAuthHeadersForMultipart());
      request.fields.addAll(fields);
      request.fields['id_depot'] = '$depotId';
      
      request.files.add(kIsWeb
          ? http.MultipartFile.fromBytes('photo', await image.readAsBytes(), filename: image.name)
          : await http.MultipartFile.fromPath('photo', image.path));

      final response = await http.Response.fromStream(await request.send());
      await TokenService.checkAndUpdateToken(response);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return (true, null, response.statusCode);
      }
      return (false, _parseError(response), response.statusCode);
    } catch (e) {
      return (false, 'Hata: $e', null);
    }
  }

  static String _parseError(http.Response r) {
    try {
      final b = json.decode(utf8.decode(r.bodyBytes));
      return b['message'] ?? b['error'] ?? 'Hata (${r.statusCode})';
    } catch (_) {
      return r.body.isNotEmpty && r.body.length < 100 ? r.body : 'Hata (${r.statusCode})';
    }
  }
}
