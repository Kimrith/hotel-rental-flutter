import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../theme/app_theme.dart';

class BookingBottomSheet extends StatefulWidget {
  final Hotel hotel;
  final HotelRoom room;
  final DateTimeRange? initialDateRange;
  final int initialGuestCount;
  final VoidCallback? onBookingConfirmed;
  final void Function(DateTime checkIn, DateTime checkOut, double totalAmount, int guestCount)? onProceedToPayment;

  const BookingBottomSheet({
    super.key,
    required this.hotel,
    required this.room,
    this.initialDateRange,
    required this.initialGuestCount,
    this.onBookingConfirmed,
    this.onProceedToPayment,
  });

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  DateTimeRange? _selectedDateRange;
  late int _guestCount;

  @override
  void initState() {
    super.initState();
    _selectedDateRange = widget.initialDateRange;
    _guestCount = widget.initialGuestCount > widget.room.guests
        ? widget.room.guests
        : widget.initialGuestCount;
  }

  @override
  Widget build(BuildContext context) {
    final selectedRoom = widget.room;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select Dates & Guests',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Room: ${selectedRoom.name} (${selectedRoom.type})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          // Date range selector row
          GestureDetector(
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDateRange: _selectedDateRange ??
                    DateTimeRange(
                      start: DateTime.now(),
                      end: DateTime.now().add(const Duration(days: 3)),
                    ),
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
                  _selectedDateRange = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDateRange == null
                            ? 'Select dates'
                            : '${_selectedDateRange!.start.month}/${_selectedDateRange!.start.day} - ${_selectedDateRange!.end.month}/${_selectedDateRange!.end.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textMuted, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Guests selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Guests',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _guestCount > 1
                        ? () {
                            setState(() {
                              _guestCount--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  Text(
                    '$_guestCount',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _guestCount < selectedRoom.guests
                        ? () {
                            setState(() {
                              _guestCount++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Summary calculations
          if (_selectedDateRange != null) ...[
            Divider(color: AppTheme.border),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${selectedRoom.price.toStringAsFixed(0)} x ${_selectedDateRange!.duration.inDays} nights',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
                Text(
                  '\$${(selectedRoom.price * _selectedDateRange!.duration.inDays).toStringAsFixed(0)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cleaning fee', style: TextStyle(color: AppTheme.textMuted)),
                const Text('\$45', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Service fee', style: TextStyle(color: AppTheme.textMuted)),
                const Text('\$25', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total (USD)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '\$${(selectedRoom.price * _selectedDateRange!.duration.inDays + 70).toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                final range = _selectedDateRange ??
                    DateTimeRange(
                      start: DateTime.now(),
                      end: DateTime.now().add(const Duration(days: 1)),
                    );
                final nights = range.duration.inDays <= 0 ? 1 : range.duration.inDays;
                final total = (selectedRoom.price * nights) + 70.0;

                if (widget.onProceedToPayment != null) {
                  widget.onProceedToPayment!(range.start, range.end, total, _guestCount);
                } else if (widget.onBookingConfirmed != null) {
                  widget.onBookingConfirmed!();
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
              child: const Text(
                'Confirm and Pay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
