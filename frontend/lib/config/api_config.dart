import 'dart:io';
import 'package:flutter/foundation.dart'; // kReleaseMode için gerekli

class ApiConfig {
  // OTOMATİK MOD:
  // Debug (Simulator/Emulator) -> false (Local Server)
  // Release (APK/Mağaza) -> true (Azure VM Remote Server)
  static const bool useRemoteServer = kReleaseMode;

  static String get baseUrl {
    if (useRemoteServer) {
        // Azure VM HTTPS (Release Modunda burası çalışır)
        // Azure DNS Label: tarladan
        return 'https://tarladan.francecentral.cloudapp.azure.com';
    }

    // Local Development (Debug Modunda burası çalışır)
    
    // Android emulator için özel mapping
    if (Platform.isAndroid) {
      return 'https://10.0.2.2:8443';
    }

    // iOS simulator ve macOS için localhost
    if (Platform.isIOS || Platform.isMacOS) {
      return 'https://localhost:8443';
    }
    
    // Web ve diğerleri
    return 'https://localhost:8443';
  }

  static const String registerEndpoint = '/api/users/register';
  static const String loginEndpoint = '/api/users/login';
  static const String verifyEndpoint = '/api/users/verify';
  static const String verifyCodeEndpoint = '/api/verification/verifyCode';
  static const String resendCodeEndpoint = '/api/verification/resendCode';
  static const String createProductEndpoint = '/farmer/product/create';
  static const String getFarmerProductsEndpoint = '/farmer/product/my-products';
  static const String getAllProductsEndpoint = '/farmer/product/all_products';
  static const String getProductDetailEndpoint = '/farmer/product/get';
  static const String updateProductEndpoint = '/farmer/product/update';
  static const String deleteProductEndpoint = '/farmer/product/delete';
  static const String createDepotEndpoint = '/depot/create';
  static const String getAllDepotsEndpoint = '/depot/all';
  static const String getDepotByIdEndpoint = '/depot';
  static const String updateDepotEndpoint = '/depot/update';
  static const String getDepotsByOwnerEndpoint = '/depot/my-depots';
  static const String deleteDepotEndpoint = '/depot';
  static const String createOrderEndpoint = '/api/orders/create';

  static const String getCustomerOrdersEndpoint = '/api/orders/my-orders';
  static const String getOrderByIdEndpoint = '/api/orders';
  static const String createTruckEndpoint = '/truck/create';
  static const String updateTruckEndpoint = '/truck/update';
  static const String deleteTruckEndpoint = '/truck/delete';
  static const String getTrucksByTruckerEndpoint = '/truck/get';
  static const String getAllTrucksEndpoint = '/truck/getAllTrucks';
  static const String createTruckAdEndpoint = '/truck/ads/create';
  static const String getTruckerAdsEndpoint = '/truck/ads/my-ads';
  static const String updateTruckAdEndpoint = '/truck/ads/update';
  static const String deleteTruckAdEndpoint = '/truck/ads/delete';
  static const String getAvailableTruckAdsEndpoint = '/truck/ads';

  // Notification endpoints
  static const String getMyNotificationsEndpoint = '/api/notifications/my-notifications';
  static const String getUnreadCountEndpoint = '/api/notifications/unread-count';
  static const String markAsReadEndpoint = '/api/notifications';

  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get verifyUrl => '$baseUrl$verifyEndpoint';
  static String get verifyCodeUrl => '$baseUrl$verifyCodeEndpoint';
  static String resendCodeUrl(String email) =>
      '$baseUrl$resendCodeEndpoint?email=$email';
  static String get createProductUrl => '$baseUrl$createProductEndpoint';
  static String get getFarmerProductsUrl =>
      '$baseUrl$getFarmerProductsEndpoint';
  static String get getAllProductsUrl => '$baseUrl$getAllProductsEndpoint';
  static String getProductDetailUrl(int productId) =>
      '$baseUrl$getProductDetailEndpoint/$productId';
  static String updateProductUrl(int productId) =>
      '$baseUrl$updateProductEndpoint/$productId';
  static String deleteProductUrl(int productId) =>
      '$baseUrl$deleteProductEndpoint/$productId';
  static String get createDepotUrl => '$baseUrl$createDepotEndpoint';
  static String get getAllDepotsUrl => '$baseUrl$getAllDepotsEndpoint';
  static String getDepotByIdUrl(int depotId) =>
      '$baseUrl$getDepotByIdEndpoint/$depotId';
  static String updateDepotUrl(int depotId) =>
      '$baseUrl$updateDepotEndpoint/$depotId';
  static String get getDepotsByOwnerUrl => '$baseUrl$getDepotsByOwnerEndpoint';
  static String deleteDepotUrl(int depotId) =>
      '$baseUrl$deleteDepotEndpoint/$depotId';
  static String get createOrderUrl => '$baseUrl$createOrderEndpoint';
  static String get getCustomerOrdersUrl =>
      '$baseUrl$getCustomerOrdersEndpoint';
  static String get getFarmerOrdersUrl => '$baseUrl$getCustomerOrdersEndpoint';
  static String getOrderByIdUrl(int orderId) =>
      '$baseUrl$getOrderByIdEndpoint/$orderId';
  static String get createTruckUrl => '$baseUrl$createTruckEndpoint';
  static String updateTruckUrl(int truckId) =>
      '$baseUrl$updateTruckEndpoint/$truckId';
  static String deleteTruckUrl(int truckId) =>
      '$baseUrl$deleteTruckEndpoint/$truckId';
  static String get getTrucksByTruckerUrl =>
      '$baseUrl$getTrucksByTruckerEndpoint';
  static String get getAllTrucksUrl => '$baseUrl$getAllTrucksEndpoint';
  static String get createTruckAdUrl => '$baseUrl$createTruckAdEndpoint';
  static String get getTruckAdsByTruckerUrl => '$baseUrl$getTruckerAdsEndpoint';
  static String updateTruckAdUrl(int adId) =>
      '$baseUrl$updateTruckAdEndpoint/$adId';
  static String deleteTruckAdUrl(int adId) =>
      '$baseUrl$deleteTruckAdEndpoint/$adId';
  static String get getAvailableTruckAdsUrl =>
      '$baseUrl$getAvailableTruckAdsEndpoint';
  
  // Notification URLs
  static String get getMyNotificationsUrl => '$baseUrl$getMyNotificationsEndpoint';
  static String get getUnreadCountUrl => '$baseUrl$getUnreadCountEndpoint';
  static String markAsReadUrl(int notificationId) =>
      '$baseUrl$markAsReadEndpoint/$notificationId/read';
}
