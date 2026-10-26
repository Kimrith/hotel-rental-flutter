import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class PaymentQrInfo {
  final String qrString;
  final String md5;
  final double amount;
  final String currency;
  final String bakongId;
  final String merchantName;
  final String merchantCity;

  const PaymentQrInfo({
    required this.qrString,
    required this.md5,
    required this.amount,
    required this.currency,
    required this.bakongId,
    required this.merchantName,
    required this.merchantCity,
  });

  factory PaymentQrInfo.fromJson(Map<String, dynamic> json) {
    return PaymentQrInfo(
      qrString: json['qrString']?.toString() ?? '',
      md5: json['md5']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      bakongId: json['bakongId']?.toString() ?? '',
      merchantName: json['merchantName']?.toString() ?? '',
      merchantCity: json['merchantCity']?.toString() ?? '',
    );
  }
}

class PaymentCheckResult {
  final bool isPaid;
  final int responseCode;
  final String responseMessage;
  final dynamic data;

  const PaymentCheckResult({
    required this.isPaid,
    required this.responseCode,
    required this.responseMessage,
    this.data,
  });

  factory PaymentCheckResult.fromJson(Map<String, dynamic> json) {
    return PaymentCheckResult(
      isPaid: json['isPaid'] == true,
      responseCode: (json['responseCode'] as num?)?.toInt() ?? -1,
      responseMessage: json['responseMessage']?.toString() ?? '',
      data: json['data'],
    );
  }
}

class PaymentOrderResult {
  final String message;
  final Map<String, dynamic>? booking;
  final Map<String, dynamic>? payment;

  const PaymentOrderResult({
    required this.message,
    this.booking,
    this.payment,
  });

  factory PaymentOrderResult.fromJson(Map<String, dynamic> json) {
    return PaymentOrderResult(
      message: json['message']?.toString() ?? '',
      booking: json['booking'] is Map ? json['booking'] as Map<String, dynamic> : null,
      payment: json['payment'] is Map ? json['payment'] as Map<String, dynamic> : null,
    );
  }
}

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  /// Generate dynamic Bakong KHQR payload + MD5 hash
  Future<PaymentQrInfo?> generateQr({
    required double amount,
    String currency = 'USD',
    String? billNumber,
  }) async {
    final url = Uri.parse(ApiConfig.generatePaymentQr);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          ...? (billNumber != null ? {'billNumber': billNumber} : null),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        return PaymentQrInfo.fromJson(decoded as Map<String, dynamic>);
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PaymentService] Error generating QR: $e');
      }
    }
    return null;
  }

  /// Check payment status using MD5 hash via NBC Bakong Open API
  Future<PaymentCheckResult?> checkTransaction(String md5) async {
    final url = Uri.parse(ApiConfig.checkPaymentTransaction);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'md5': md5}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        return PaymentCheckResult.fromJson(decoded as Map<String, dynamic>);
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PaymentService] Error checking transaction: $e');
      }
    }
    return null;
  }

  /// Process order with required payment rule:
  /// - If KHQR: Must be paid first. Backend verifies MD5. Only paid orders are pushed to DB.
  /// - If CASH: Pushed to DB with PENDING status.
  Future<PaymentOrderResult> processOrder({
    required int customerId,
    required int hotelId,
    required int roomTypeId,
    required String checkInDate, // yyyy-MM-dd
    required String checkOutDate, // yyyy-MM-dd
    required String paymentMethod, // 'KHQR' or 'CASH'
    required double amount,
    String? md5,
  }) async {
    final url = Uri.parse(ApiConfig.orderPayment);
    final payload = {
      'customerId': customerId,
      'hotelId': hotelId,
      'roomTypeId': roomTypeId,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'paymentMethod': paymentMethod,
      'amount': amount,
      ...? (md5 != null ? {'md5': md5} : null),
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return PaymentOrderResult.fromJson(decoded as Map<String, dynamic>);
    } else {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Payment order failed (${response.statusCode}): $body');
    }
  }
}
