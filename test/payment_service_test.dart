import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_rental/services/payment_service.dart';

void main() {
  final paymentService = PaymentService();

  test('PaymentService generates Bakong KHQR with MD5', () async {
    final qrInfo = await paymentService.generateQr(amount: 85.50, currency: 'USD');

    expect(qrInfo, isNotNull);
    expect(qrInfo!.qrString.isNotEmpty, true);
    expect(qrInfo.md5.isNotEmpty, true);
    expect(qrInfo.amount, 85.50);
    expect(qrInfo.bakongId, 'chey_kimrith@bkrt');
  });

  test('PaymentService checks transaction status via MD5', () async {
    // Generate a new QR first
    final qrInfo = await paymentService.generateQr(amount: 50.0, currency: 'USD');
    expect(qrInfo, isNotNull);

    // Check with Bakong Open API
    final checkResult = await paymentService.checkTransaction(qrInfo!.md5);
    expect(checkResult, isNotNull);
    // Since this is an unpaid newly generated QR, isPaid should be false
    expect(checkResult!.isPaid, false);
  });

  test('PaymentService enforces KHQR paid rule (fails if unpaid)', () async {
    expect(
      () async => await paymentService.processOrder(
        customerId: 1,
        hotelId: 1,
        roomTypeId: 1,
        checkInDate: '2026-11-10',
        checkOutDate: '2026-11-12',
        paymentMethod: 'KHQR',
        amount: 130.0,
        md5: '00000000000000000000000000000000',
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('PaymentService successfully pushes CASH orders with PENDING status', () async {
    final start = DateTime.now().add(Duration(days: 60 + (DateTime.now().second)));
    final end = start.add(const Duration(days: 2));
    final checkIn = '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final checkOut = '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

    final result = await paymentService.processOrder(
      customerId: 1,
      hotelId: 1,
      roomTypeId: 1,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      paymentMethod: 'CASH',
      amount: 130.0,
    );

    expect(result.message.isNotEmpty, true);
    expect(result.booking, isNotNull);
    expect(result.booking!['status'], 'PENDING');
    expect(result.payment, isNotNull);
    expect(result.payment!['paymentStatus'], 'PENDING');
    expect(result.payment!['paymentMethod'], 'CASH');
  });
}
