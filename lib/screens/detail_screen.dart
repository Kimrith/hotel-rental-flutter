import 'package:flutter/material.dart';
import '../../models/hotel.dart';
import '../../services/hotel_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_image.dart';
import '../../widgets/payment_dialog.dart';
import '../../widgets/room_detail_bottom_sheet.dart';

class DetailScreen extends StatefulWidget {
  final Hotel hotel;
  final String heroTag;

  const DetailScreen({super.key, required this.hotel, required this.heroTag});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;
  late PageController _pageController;

  int _selectedRoomIndex = 0;
  String _selectedRoomCategory = 'All';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleFavorite() async {
    await HotelService().toggleFavorite(widget.hotel);
    if (mounted) {
      setState(() {});
    }
  }

  IconData _getIconFromKey(String key) {
    switch (key) {
      case 'spa':
        return Icons.spa_rounded;
      case 'pool':
        return Icons.pool_rounded;
      case 'wifi':
        return Icons.wifi_rounded;
      case 'fireplace':
        return Icons.fireplace_rounded;
      case 'kitchen':
        return Icons.kitchen_rounded;
      case 'beach_access':
        return Icons.beach_access_rounded;
      case 'ac_unit':
        return Icons.ac_unit_rounded;
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      case 'yard':
        return Icons.yard_rounded;
      case 'bathtub':
        return Icons.bathtub_rounded;
      case 'coffee_maker':
        return Icons.coffee_maker_rounded;
      case 'pedal_bike':
        return Icons.pedal_bike_rounded;
      case 'wb_sunny':
        return Icons.wb_sunny_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'deck':
        return Icons.deck_rounded;
      case 'local_bar':
        return Icons.local_bar_rounded;
      case 'location_city':
        return Icons.location_city_rounded;
      case 'laptop':
        return Icons.laptop_chromebook_rounded;
      case 'elevator':
        return Icons.elevator_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Sliding Image Header
              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                stretch: true,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 18),
                      ),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: GestureDetector(
                        onTap: _toggleFavorite,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.hotel.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: widget.hotel.isFavorite ? Colors.red : AppTheme.textDark,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: widget.hotel.imageUrls.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Hero(
                            tag: index == 0 ? widget.heroTag : 'hotel-img-alt-${widget.hotel.id}-$index',
                            child: AppImage(
                              imageUrl: widget.hotel.imageUrls[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        },
                      ),
                      // Carousel Indicator
                      Positioned(
                        bottom: 24,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(widget.hotel.imageUrls.length, (index) {
                            final isActive = index == _currentImageIndex;
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
                ),
              ),
              // Detail Information Content
              SliverToBoxAdapter(
                child: Container(
                  color: AppTheme.background,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildThumbnailGallery(),
                      const SizedBox(height: 20),
                      // Location Pin + Stars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${widget.hotel.city}, ${widget.hotel.country}',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star_rounded, color: AppTheme.accent, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                widget.hotel.rating.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${widget.hotel.reviewsCount} reviews)',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Hotel Title
                      Text(
                        widget.hotel.name,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Specs Row (Guests, Beds, Bathrooms)
                      Row(
                        children: [
                          _buildSpecItem(Icons.group_rounded, '${widget.hotel.guests} Guests'),
                          _buildVerticalDivider(),
                          _buildSpecItem(Icons.king_bed_rounded, '${widget.hotel.beds} Beds'),
                          _buildVerticalDivider(),
                          _buildSpecItem(Icons.bathtub_rounded, '${widget.hotel.baths} Baths'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildRoomSelector(),
                      const SizedBox(height: 24),
                      Divider(color: AppTheme.border),
                      const SizedBox(height: 16),
                      // Description
                      Text(
                        'Description',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.hotel.description,
                        style: TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.6),
                        maxLines: _isDescriptionExpanded ? null : 3,
                        overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isDescriptionExpanded = !_isDescriptionExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            _isDescriptionExpanded ? 'Read Less' : 'Read More',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Divider(color: AppTheme.border),
                      const SizedBox(height: 16),
                      // Amenities Grid
                      Text(
                        'Offers & Amenities',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3.5,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 16,
                        ),
                        itemCount: widget.hotel.amenities.length,
                        itemBuilder: (context, index) {
                          final amenity = widget.hotel.amenities[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              children: [
                                Icon(_getIconFromKey(amenity.iconKey), color: AppTheme.primary, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    amenity.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      Divider(color: AppTheme.border),
                      const SizedBox(height: 16),
                      // Location Map Section
                      Text(
                        'Location',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 16),
                      _buildMockMap(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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

  Widget _buildMockMap() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: AppTheme.border),
      ),
      child: Stack(
        children: [
          // Map Background graphic lines
          Positioned.fill(
            child: CustomPaint(
              painter: MapGraphicsPainter(),
            ),
          ),
          // Map Marker Card
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Icon(
                    Icons.home_work_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Text(
                    widget.hotel.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Interactive overlay buttons
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.my_location_rounded, color: AppTheme.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }








  Widget _buildRoomSelector() {
    final categories = ['All', 'Normal', 'VIP'];
    final filteredRooms = widget.hotel.rooms.where((room) {
      if (_selectedRoomCategory == 'All') return true;
      return room.type == _selectedRoomCategory;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Room',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 16),
        // Category Chips List
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == _selectedRoomCategory;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRoomCategory = category;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textMuted,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // Rooms List
        SizedBox(
          height: 140,
          child: filteredRooms.isEmpty
              ? Center(
                  child: Text(
                    'No rooms available in this category',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredRooms.length,
                  itemBuilder: (context, index) {
                    final room = filteredRooms[index];
                    final originalIndex = widget.hotel.rooms.indexOf(room);
                    final isSelected = originalIndex == _selectedRoomIndex;
                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return RoomDetailBottomSheet(
                              room: room,
                              roomIndex: originalIndex,
                              onBookPressed: () {
                                Navigator.pop(context); // Close details modal
                                setState(() {
                                  _selectedRoomIndex = originalIndex;
                                });
                                // Show payment popup asking user to pay with CASH or Bakong KHQR
                                PaymentDialog.show(
                                  context,
                                  hotel: widget.hotel,
                                  room: room,
                                  checkInDate: DateTime.now(),
                                  checkOutDate: DateTime.now().add(const Duration(days: 1)),
                                  totalAmount: room.price,
                                  guestCount: room.guests,
                                );
                              },
                            );
                          },
                        );
                      },
                      child: _buildRoomCard(room, isSelected),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRoomCard(HotelRoom room, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppTheme.primary : AppTheme.border,
          width: isSelected ? 2.5 : 1,
        ),
        boxShadow: isSelected ? AppTheme.cardShadow : AppTheme.softShadow,
      ),
      child: Row(
        children: [
          // Room Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AppImage(
              imageUrl: room.imageUrl,
              width: 100,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Room Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: room.type == 'VIP'
                        ? const Color(0xFFF59E0B) // Amber
                        : const Color(0xFF64748B), // Slate
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    room.type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  room.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Room Specs
                Row(
                  children: [
                    Icon(Icons.king_bed_rounded, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${room.beds} Beds',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.group_rounded, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${room.guests} Guests',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Price
                RichText(
                  text: TextSpan(
                    text: '\$${room.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                    children: [
                      TextSpan(
                        text: ' / night',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo Gallery',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 64,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.hotel.imageUrls.length,
            itemBuilder: (context, index) {
              final isSelected = index == _currentImageIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentImageIndex = index;
                  });
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  width: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.border,
                      width: isSelected ? 2.5 : 1,
                    ),
                    image: DecorationImage(
                      image: AppImage.provider(widget.hotel.imageUrls[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Custom Painter to draw stylized map streets
class MapGraphicsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadColorAccent = Paint()
      ..color = AppTheme.primaryLight.withOpacity(0.6)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw main roads
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.5), paint);
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.6, size.height), paint);
    
    // Draw an accent avenue
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.8, size.height), roadColorAccent);

    // Draw a curved river/lake outline in light blue
    final riverPaint = Paint()
      ..color = const Color(0xFFBAE6FD) // Light blue
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.6, size.width * 0.7, size.height * 0.9);
    path.lineTo(size.width, size.height * 0.8);

    canvas.drawPath(path, riverPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


