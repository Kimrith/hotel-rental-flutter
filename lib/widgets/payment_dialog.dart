import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/hotel.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../theme/app_theme.dart';

enum PaymentMethodType { khqr, cash }

enum PaymentStep { chooseMethod, khqrWaiting, processing, success, failed }

class PaymentDialog extends StatefulWidget {
  final Hotel hotel;
  final HotelRoom room;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double totalAmount;
  final int guestCount;
  final VoidCallback? onBookingCompleted;

  const PaymentDialog({
    super.key,
    required this.hotel,
    required this.room,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalAmount,
    this.guestCount = 2,
    this.onBookingCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    required Hotel hotel,
    required HotelRoom room,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required double totalAmount,
    int guestCount = 2,
    VoidCallback? onBookingCompleted,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PaymentDialog(
        hotel: hotel,
        room: room,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        totalAmount: totalAmount,
        guestCount: guestCount,
        onBookingCompleted: onBookingCompleted,
      ),
    );
  }

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final PaymentService _paymentService = PaymentService();

  PaymentMethodType _selectedMethod = PaymentMethodType.khqr;
  PaymentStep _currentStep = PaymentStep.chooseMethod;

  PaymentQrInfo? _qrInfo;
  PaymentOrderResult? _orderResult;
  String? _errorMessage;
  bool _isLoading = false;

  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  late double _totalAmount;

  Timer? _pollingTimer;
  int _pollCount = 0;
  static const int _maxPollAttempts = 60; // 3 minutes polling

  @override
  void initState() {
    super.initState();
    _checkInDate = widget.checkInDate;
    _checkOutDate = widget.checkOutDate;
    _totalAmount = widget.totalAmount;
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  int get _totalNights {
    final nights = _checkOutDate.difference(_checkInDate).inDays;
    return nights <= 0 ? 1 : nights;
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _checkInDate, end: _checkOutDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _checkInDate = picked.start;
        _checkOutDate = picked.end;
        final nights = picked.duration.inDays <= 0 ? 1 : picked.duration.inDays;
        _totalAmount = nights * widget.room.price;
      });
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  int get _hotelId => int.tryParse(widget.hotel.id) ?? 1;
  int get _roomTypeId => widget.room.id ?? 1;

  // ---------------------------------------------------------------------------
  // Action: Generate QR for Bakong KHQR
  // ---------------------------------------------------------------------------
  Future<void> _startKhqrFlow() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final qr = await _paymentService.generateQr(
        amount: _totalAmount,
        currency: 'USD',
        billNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      );

      if (qr != null && qr.qrString.isNotEmpty && qr.md5.isNotEmpty) {
        setState(() {
          _qrInfo = qr;
          _currentStep = PaymentStep.khqrWaiting;
          _isLoading = false;
        });
        _startAutoPolling(qr.md5);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not generate Bakong KHQR. Please check server connection.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error generating QR: $e';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Auto-poll Bakong status by MD5
  // ---------------------------------------------------------------------------
  void _startAutoPolling(String md5) {
    _pollingTimer?.cancel();
    _pollCount = 0;

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _pollCount++;
      if (_pollCount > _maxPollAttempts) {
        timer.cancel();
        return;
      }

      final check = await _paymentService.checkTransaction(md5);
      if (check != null && check.isPaid) {
        timer.cancel();
        _finalizeOrder(paymentMethod: 'KHQR', md5: md5);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Manual Verify Button for KHQR
  // ---------------------------------------------------------------------------
  Future<void> _manualCheckPayment() async {
    if (_qrInfo == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final check = await _paymentService.checkTransaction(_qrInfo!.md5);
    if (check != null && check.isPaid) {
      _pollingTimer?.cancel();
      await _finalizeOrder(paymentMethod: 'KHQR', md5: _qrInfo!.md5);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Payment not received yet. Please scan the QR code and authorize payment in your Bakong/banking app.';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Confirm Cash Order
  // ---------------------------------------------------------------------------
  Future<void> _submitCashOrder() async {
    await _finalizeOrder(paymentMethod: 'CASH');
  }

  // ---------------------------------------------------------------------------
  // Finalize Order with Backend API
  // ---------------------------------------------------------------------------
  Future<void> _finalizeOrder({
    required String paymentMethod,
    String? md5,
  }) async {
    setState(() {
      _currentStep = PaymentStep.processing;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _paymentService.processOrder(
        customerId: AuthService().userId,
        hotelId: _hotelId,
        roomTypeId: _roomTypeId,
        checkInDate: _formatDate(_checkInDate),
        checkOutDate: _formatDate(_checkOutDate),
        paymentMethod: paymentMethod,
        amount: _totalAmount,
        md5: md5,
      );

      setState(() {
        _orderResult = result;
        _currentStep = PaymentStep.success;
        _isLoading = false;
      });
    } catch (e) {
      final cleanMsg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _currentStep = paymentMethod == 'KHQR' ? PaymentStep.khqrWaiting : PaymentStep.chooseMethod;
        _isLoading = false;
        _errorMessage = cleanMsg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppTheme.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildCurrentStepContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case PaymentStep.chooseMethod:
        return _buildMethodSelectionView();
      case PaymentStep.khqrWaiting:
        return _buildKhqrDisplayView();
      case PaymentStep.processing:
        return _buildProcessingView();
      case PaymentStep.success:
        return _buildSuccessView();
      case PaymentStep.failed:
        return _buildFailedView();
    }
  }

  // ===========================================================================
  // Step 1: Choose Payment Method (CASH or KHQR)
  // ===========================================================================
  Widget _buildMethodSelectionView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose how you would like to pay',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close_rounded, color: AppTheme.textMuted),
              splashRadius: 20,
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.room.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.hotel.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.room.type,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
              InkWell(
                onTap: _pickDateRange,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.edit_calendar_rounded, size: 15, color: AppTheme.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${_formatDisplayDate(_checkInDate)} - ${_formatDisplayDate(_checkOutDate)} ($_totalNights night${_totalNights > 1 ? 's' : ''})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${_totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Error message if any
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(fontSize: 12, color: Colors.red.shade800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Option 1: Bakong KHQR
        _buildPaymentOptionCard(
          type: PaymentMethodType.khqr,
          title: 'Bakong KHQR',
          subtitle: 'Instant pay with Bakong, ABA, ACLEDA, Wing or any KHQR app',
          badgeText: 'Instant Confirm',
          iconColor: const Color(0xFFDC2626), // Bakong Crimson Red
          iconBgColor: const Color(0xFFFEE2E2),
          icon: Icons.qr_code_scanner_rounded,
        ),
        const SizedBox(height: 12),

        // Option 2: Pay with Cash
        _buildPaymentOptionCard(
          type: PaymentMethodType.cash,
          title: 'Pay with Cash',
          subtitle: 'Pay at reception upon check-in. Booking reserved as PENDING',
          badgeText: 'Pay on Arrival',
          iconColor: const Color(0xFF059669), // Emerald
          iconBgColor: const Color(0xFFD1FAE5),
          icon: Icons.payments_rounded,
        ),
        const SizedBox(height: 24),

        // Action Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    if (_selectedMethod == PaymentMethodType.khqr) {
                      _startKhqrFlow();
                    } else {
                      _submitCashOrder();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    _selectedMethod == PaymentMethodType.khqr
                        ? 'Generate KHQR & Pay (\$${_totalAmount.toStringAsFixed(2)})'
                        : 'Confirm Cash Booking (\$${_totalAmount.toStringAsFixed(2)})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOptionCard({
    required PaymentMethodType type,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color iconColor,
    required Color iconBgColor,
    required IconData icon,
  }) {
    final isSelected = _selectedMethod == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = type;
          _errorMessage = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight.withOpacity(0.35) : AppTheme.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.border,
                  width: 2,
                ),
                color: isSelected ? AppTheme.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Step 2: Bakong KHQR Display & Verification
  // ===========================================================================
  Widget _buildKhqrDisplayView() {
    if (_qrInfo == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _pollingTimer?.cancel();
                    setState(() {
                      _currentStep = PaymentStep.chooseMethod;
                      _errorMessage = null;
                    });
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  splashRadius: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  'Scan to Pay',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                _pollingTimer?.cancel();
                Navigator.pop(context);
              },
              icon: Icon(Icons.close_rounded, color: AppTheme.textMuted),
              splashRadius: 20,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Bakong KHQR Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE11D48), Color(0xFFBE123C)], // Crimson Bakong
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE11D48).withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'KHQR',
                      style: TextStyle(
                        color: Color(0xFFE11D48),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Bakong Individual',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _qrInfo!.merchantName.isNotEmpty ? _qrInfo!.merchantName : 'Ecommerce',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '${_qrInfo!.bakongId} • ${_qrInfo!.merchantCity}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '\$${_qrInfo!.amount.toStringAsFixed(2)} ${_qrInfo!.currency}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Offline high-precision vector QR code
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.softShadow,
          ),
          child: QrImageView(
            data: _qrInfo!.qrString,
            version: QrVersions.auto,
            size: 190,
            gapless: true,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Color(0xFF1E293B),
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Quick Copy QR Data
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: _qrInfo!.qrString));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('KHQR String copied to clipboard!'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.copy_rounded, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                Text(
                  'Copy QR Data',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Live listening radar / status
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Listening for transaction from Bakong...',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'MD5: ${_qrInfo!.md5.substring(0, 12)}...',
          style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
        ),

        // Error message if verify failed
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Text(
              _errorMessage!,
              style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Verify button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _manualCheckPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'I Have Paid • Verify Status',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Step: Processing
  // ===========================================================================
  Widget _buildProcessingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        SizedBox(
          width: 54,
          height: 54,
          child: CircularProgressIndicator(
            color: AppTheme.primary,
            strokeWidth: 3.5,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Securing Your Reservation...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connecting to server and reserving room',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ===========================================================================
  // Step 3: Success Confirmation
  // ===========================================================================
  Widget _buildSuccessView() {
    final isKhqr = _selectedMethod == PaymentMethodType.khqr;
    final bookingId = _orderResult?.booking?['id']?.toString() ?? 'CONFIRMED';
    final bookingStatus = _orderResult?.booking?['status']?.toString() ?? (isKhqr ? 'APPROVED' : 'PENDING');
    final paymentStatus = _orderResult?.payment?['paymentStatus']?.toString() ?? (isKhqr ? 'SUCCESS' : 'PENDING');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Success Icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isKhqr ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isKhqr ? Icons.check_circle_rounded : Icons.schedule_rounded,
            color: isKhqr ? const Color(0xFF059669) : const Color(0xFFD97706),
            size: 54,
          ),
        ),
        const SizedBox(height: 18),

        // Title
        Text(
          isKhqr ? 'Payment & Booking Confirmed!' : 'Booking Reserved (Pending Cash)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          isKhqr
              ? 'Your Bakong transaction was verified and your room is reserved.'
              : 'Your booking has been saved. Please pay \$${_totalAmount.toStringAsFixed(2)} cash at check-in.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),

        // Receipt Details
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              _buildReceiptRow('Booking Reference', '#$bookingId'),
              const SizedBox(height: 8),
              _buildReceiptRow('Hotel', widget.hotel.name),
              const SizedBox(height: 8),
              _buildReceiptRow('Room', widget.room.name),
              const SizedBox(height: 8),
              _buildReceiptRow('Check-in', _formatDisplayDate(_checkInDate)),
              const SizedBox(height: 8),
              _buildReceiptRow('Check-out', _formatDisplayDate(_checkOutDate)),
              const Divider(height: 16),
              _buildReceiptRow('Booking Status', bookingStatus, isBadge: true, badgeColor: isKhqr ? Colors.green : Colors.orange),
              const SizedBox(height: 6),
              _buildReceiptRow('Payment Status', paymentStatus, isBadge: true, badgeColor: isKhqr ? Colors.green : Colors.orange),
              const SizedBox(height: 8),
              _buildReceiptRow(
                'Total Amount',
                '\$${_totalAmount.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Close Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onBookingCompleted?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Back to Explorer',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isBold = false,
    bool isBadge = false,
    Color? badgeColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (isBadge && badgeColor != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: badgeColor,
              ),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? AppTheme.primary : AppTheme.textDark,
            ),
          ),
      ],
    );
  }

  Widget _buildFailedView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        Text(
          'Booking Failed',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage ?? 'An unexpected error occurred.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _currentStep = PaymentStep.chooseMethod;
              _errorMessage = null;
            });
          },
          child: const Text('Try Again'),
        ),
      ],
    );
  }
}
