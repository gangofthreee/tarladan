class ApiConfig {
  static String get baseUrl {
    // macOS için localhost, diğer cihazlar için gerçek IP
    // Geliştirme sırasında: macOS -> localhost, mobil cihaz -> 192.168.1.98
    return 'http://localhost:8080';

    // Fiziksel cihaz test için (aynı WiFi'de):
    // return 'http://192.168.1.98:8080';

    // Eski IP (artık kullanılmıyor):
    // return 'http://172.20.10.2:8080';

    // Web platform kontrolü
    // if (kIsWeb) {
    //   return 'http://localhost:8080';
    // }

    // Android emulator
    // if (Platform.isAndroid) {
    //   return 'http://10.0.2.2:8080';
    // }

    // iOS simulator veya macOS
    // if (Platform.isIOS || Platform.isMacOS) {
    //   return 'http://localhost:8080';
    // }

    // Diğer platformlar (Windows, Linux)
    // return 'http://localhost:8080';
  }

  static const String registerEndpoint = '/api/users/register';
  static const String loginEndpoint = '/api/users/login';
  static const String verifyEndpoint = '/api/users/verify';
  static const String verifyCodeEndpoint = '/api/verification/verifyCode';
  static const String resendCodeEndpoint = '/api/verification/resendCode';
  static const String createProductEndpoint = '/farmer/product/create';
  static const String getFarmerProductsEndpoint =
      '/farmer/product/getFarmerProduct';
  static const String getProductDetailEndpoint = '/farmer/product/get';
  static const String updateProductEndpoint = '/farmer/product/update';
  static const String deleteProductEndpoint = '/farmer/product/delete';
  static const String createDepotEndpoint = '/depot/create';
  static const String getAllDepotsEndpoint = '/depot/all';
  static const String getDepotByIdEndpoint = '/depot';
  static const String updateDepotEndpoint = '/depot/update';
  static const String getDepotsByOwnerEndpoint = '/depot/owner';
  static const String deleteDepotEndpoint = '/depot';
  static const String createOrderEndpoint = '/api/orders/create';
  static const String getOrdersByCustomerEndpoint = '/api/orders/customer';
  static const String getOrderByIdEndpoint = '/api/orders';
  static const String createTruckEndpoint = '/truck/create';
  static const String updateTruckEndpoint = '/truck/update';
  static const String deleteTruckEndpoint = '/truck/delete';
  static const String getTrucksByTruckerEndpoint = '/truck/get';
  static const String getAllTrucksEndpoint = '/truck/getAllTrucks';

  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get verifyUrl => '$baseUrl$verifyEndpoint';
  static String get verifyCodeUrl => '$baseUrl$verifyCodeEndpoint';
  static String resendCodeUrl(String email) =>
      '$baseUrl$resendCodeEndpoint?email=$email';
  static String get createProductUrl => '$baseUrl$createProductEndpoint';
  static String getFarmerProductsUrl(int farmerId) =>
      '$baseUrl$getFarmerProductsEndpoint/$farmerId';
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
  static String getDepotsByOwnerUrl(int depoOwnerId) =>
      '$baseUrl$getDepotsByOwnerEndpoint/$depoOwnerId';
  static String deleteDepotUrl(int depotId) =>
      '$baseUrl$deleteDepotEndpoint/$depotId';
  static String get createOrderUrl => '$baseUrl$createOrderEndpoint';
  static String getOrdersByCustomerUrl(int customerId) =>
      '$baseUrl$getOrdersByCustomerEndpoint/$customerId';
  static String getOrderByIdUrl(int orderId) =>
      '$baseUrl$getOrderByIdEndpoint/$orderId';
  static String get createTruckUrl => '$baseUrl$createTruckEndpoint';
  static String updateTruckUrl(int truckId) =>
      '$baseUrl$updateTruckEndpoint/$truckId';
  static String deleteTruckUrl(int truckId) =>
      '$baseUrl$deleteTruckEndpoint/$truckId';
  static String getTrucksByTruckerUrl(int truckerId) =>
      '$baseUrl$getTrucksByTruckerEndpoint/$truckerId';
  static String get getAllTrucksUrl => '$baseUrl$getAllTrucksEndpoint';
}
