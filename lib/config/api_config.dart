import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // ---------------------------------------------------------------------------
  // Swagger Documentation Link (For Browser Reference)
  // ---------------------------------------------------------------------------
  static String get swaggerDocUrl =>
      (dotenv.isInitialized ? dotenv.env['SWAGGER_URL'] : null) ??
      'http://localhost:8030/swagger-ui/index.html';

  // ---------------------------------------------------------------------------
  // API Host & Base URL Setup
  // ---------------------------------------------------------------------------
  static const int port = 8030;

  /// Returns the base URL with smart fallback for Android vs Desktop/Web:
  /// - Web / Desktop (Windows, macOS, Linux) / iOS: http://localhost:8030
  /// - Android Emulator: http://10.0.2.2:8030
  static String get baseUrl {
    final envUrl = dotenv.isInitialized ? dotenv.env['API_BASE_URL'] : null;
    if (kIsWeb) {
      if (envUrl != null && envUrl.isNotEmpty && !envUrl.contains('10.0.2.2')) {
        return envUrl;
      }
      return 'http://localhost:$port';
    } else if (Platform.isAndroid) {
      if (envUrl != null && envUrl.isNotEmpty) {
        return envUrl;
      }
      return 'http://10.0.2.2:$port';
    } else {
      // Windows Desktop, macOS, Linux, iOS
      if (envUrl != null && envUrl.isNotEmpty && !envUrl.contains('10.0.2.2')) {
        return envUrl;
      }
      return 'http://localhost:$port';
    }
  }

  // ---------------------------------------------------------------------------
  // Hotel Controller API Endpoints (Swagger /api/v1/hotels)
  // ---------------------------------------------------------------------------
  static String get hotels => '$baseUrl/api/v1/hotels';
  static String hotelById(dynamic id) => '$baseUrl/api/v1/hotels/$id';
  static String hotelRoomTypes(dynamic hotelId) => '$baseUrl/api/v1/room-types/hotel/$hotelId';
  static String hotelImages(dynamic hotelId) => '$baseUrl/api/v1/hotel-images/hotel/$hotelId';
  static String hotelReviews(dynamic hotelId) => '$baseUrl/api/v1/reviews/hotel/$hotelId';

  // ---------------------------------------------------------------------------
  // Favorite Controller API Endpoints (Swagger /api/v1/favorites)
  // ---------------------------------------------------------------------------
  static String get favorites => '$baseUrl/api/v1/favorites';
  static String favoriteById(dynamic id) => '$baseUrl/api/v1/favorites/$id';

  // ---------------------------------------------------------------------------
  // Payment Controller API Endpoints (Swagger /api/v1/payments)
  // ---------------------------------------------------------------------------
  static String get payments => '$baseUrl/api/v1/payments';
  static String get generatePaymentQr => '$baseUrl/api/v1/payments/generate-qr';
  static String get checkPaymentTransaction => '$baseUrl/api/v1/payments/check-transaction';
  static String get orderPayment => '$baseUrl/api/v1/payments/order';
  static String paymentById(dynamic id) => '$baseUrl/api/v1/payments/$id';
  static String paymentsByBookingId(dynamic bookingId) => '$baseUrl/api/v1/payments/booking/$bookingId';
}
