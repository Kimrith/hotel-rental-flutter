import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../theme/app_theme.dart';
import 'app_image.dart';

class RoomDetailBottomSheet extends StatefulWidget {
  final HotelRoom room;
  final int roomIndex;
  final VoidCallback onBookPressed;

  const RoomDetailBottomSheet({
    super.key,
    required this.room,
    required this.roomIndex,
    required this.onBookPressed,
  });

  @override
  State<RoomDetailBottomSheet> createState() => _RoomDetailBottomSheetState();
}

class _RoomDetailBottomSheetState extends State<RoomDetailBottomSheet> {
  int _currentRoomImageIndex = 0;

  Widget _buildSpecItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textMuted, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 14,
      width: 1,
      color: AppTheme.border,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room Images Carousel
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(
                      height: 260,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                        child: PageView.builder(
                          itemCount: room.imageUrls.length,
                          onPageChanged: (idx) {
                            setState(() {
                              _currentRoomImageIndex = idx;
                            });
                          },
                          itemBuilder: (context, idx) {
                            return AppImage(
                              imageUrl: room.imageUrls[idx],
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                    if (room.imageUrls.length > 1)
                      Positioned(
                        bottom: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(room.imageUrls.length, (idx) {
                            final isActive = idx == _currentRoomImageIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 6,
                              width: isActive ? 20 : 6,
                              decoration: BoxDecoration(
                                color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room Title & Price Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.name,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: room.type == 'VIP'
                                        ? const Color(0xFFF59E0B) // Amber
                                        : const Color(0xFF64748B), // Slate
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${room.type} Class',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          RichText(
                            text: TextSpan(
                              text: '\$${room.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                              children: [
                                TextSpan(
                                  text: ' / night',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Specs Row
                      Row(
                        children: [
                          _buildSpecItem(Icons.king_bed_rounded, '${room.beds} Beds'),
                          _buildVerticalDivider(),
                          _buildSpecItem(Icons.group_rounded, '${room.guests} Guests'),
                          _buildVerticalDivider(),
                          _buildSpecItem(Icons.bathtub_rounded, '${room.baths} Baths'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(color: AppTheme.border),
                      const SizedBox(height: 16),
                      // Amenities Section
                      Text(
                        'Room Amenities',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: room.amenities.map((amenity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              amenity,
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Divider(color: AppTheme.border),
                      const SizedBox(height: 16),
                      // Room Description / details
                      Text(
                        'About this Room',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Experience premium luxury and comfort in this room. Fully furnished with high-speed internet, premium air conditioning, and top-tier amenities styled to perfection.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 120), // Spacing for bottom button
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Close Button
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.softShadow,
                ),
                child: Icon(Icons.close_rounded, color: AppTheme.textDark, size: 20),
              ),
            ),
          ),
          // Booking Action Button at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: widget.onBookPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Book This Room',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
