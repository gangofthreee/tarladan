import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    // TLS ile nginx reverse proxy kullanılıyor (443 port)
    // nginx → backend:8080 yönlendirmesi yapıyor

    // Android emulator için özel mapping
    if (Platform.isAndroid) {
      // Android emulator'da localhost yerine 10.0.2.2 kullan
      return 'https://10.0.2.2';
    }

    // iOS simulator ve macOS için localhost
    if (Platform.isIOS || Platform.isMacOS) {
      return 'https://localhost';
    }

    // Web ve diğer platformlar
    return 'https://localhost';

    // Fiziksel cihaz test için (aynı WiFi'de):
    // Backend çalıştıran makinenin IP'sini kullan
    // return 'https://192.168.1.98';
  }

  static const String registerEndpoint = '/api/users/register';
  static const String loginEndpoint = '/api/users/login';
  static const String verifyEndpoint = '/api/users/verify';
  static const String verifyCodeEndpoint = '/api/verification/verifyCode';
  static const String resendCodeEndpoint = '/api/verification/resendCode';
  static const String createProductEndpoint = '/farmer/product/create';
  static const String getFarmerProductsEndpoint = '/farmer/product/my-products';
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
  static const String getOrdersByCustomerEndpoint =
      '/api/orders/customer/my-orders';
  static const String getFarmerOrdersEndpoint = '/api/orders/my-orders';
  static const String getOrderByIdEndpoint = '/api/orders';
  static const String createTruckEndpoint = '/truck/create';
  static const String updateTruckEndpoint = '/truck/update';
  static const String deleteTruckEndpoint = '/truck/delete';
  static const String getTrucksByTruckerEndpoint = '/truck/get';
  static const String getAllTrucksEndpoint = '/truck/getAllTrucks';
  static const String createTruckAdEndpoint = '/truck/ads/create';
  static const String getTruckerAdsEndpoint = '/truck/ads/my-ads';
  static const String updateTruckAdEndpoint = '/truck/ads/update';

  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get verifyUrl => '$baseUrl$verifyEndpoint';
  static String get verifyCodeUrl => '$baseUrl$verifyCodeEndpoint';
  static String resendCodeUrl(String email) =>
      '$baseUrl$resendCodeEndpoint?email=$email';
  static String get createProductUrl => '$baseUrl$createProductEndpoint';
  static String get getFarmerProductsUrl =>
      '$baseUrl$getFarmerProductsEndpoint';
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
  static String get getOrdersByCustomerUrl =>
      '$baseUrl$getOrdersByCustomerEndpoint';
  static String get getFarmerOrdersUrl => '$baseUrl$getFarmerOrdersEndpoint';
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
  static String get getTruckerAdsUrl => '$baseUrl$getTruckerAdsEndpoint';
  static String updateTruckAdUrl(int adId) =>
      '$baseUrl$updateTruckAdEndpoint/$adId';
}
