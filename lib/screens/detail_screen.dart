import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../theme/app_theme.dart';

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

  // Simple state for booking date selections
  DateTimeRange? _selectedDateRange;
  int _guestCount = 2;

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

  void _toggleFavorite() {
    setState(() {
      widget.hotel.isFavorite = !widget.hotel.isFavorite;
    });
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
                            child: Image.network(
                              widget.hotel.imageUrls[index],
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
                      const SizedBox(height: 100), // Spacing for floating bottom action
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Floating Bottom Booking Action
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomActionBar(context),
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

  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price per night',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  text: '\$${widget.hotel.price.toStringAsFixed(0)}',
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
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _showBookingDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Book Now',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
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
                        setModalState(() {
                          _selectedDateRange = picked;
                        });
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
                                    setModalState(() {
                                      _guestCount--;
                                    });
                                    setState(() {
                                      _guestCount = _guestCount;
                                    });
                                  }
                                : null,
                            icon: Icon(Icons.remove_circle_outline_rounded),
                          ),
                          Text(
                            '$_guestCount',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: _guestCount < widget.hotel.guests
                                ? () {
                                    setModalState(() {
                                      _guestCount++;
                                    });
                                    setState(() {
                                      _guestCount = _guestCount;
                                    });
                                  }
                                : null,
                            icon: Icon(Icons.add_circle_outline_rounded),
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
                          '\$${widget.hotel.price.toStringAsFixed(0)} x ${_selectedDateRange!.duration.inDays} nights',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                        Text(
                          '\$${(widget.hotel.price * _selectedDateRange!.duration.inDays).toStringAsFixed(0)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Cleaning fee', style: TextStyle(color: AppTheme.textMuted)),
                        Text('\$45', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Service fee', style: TextStyle(color: AppTheme.textMuted)),
                        Text('\$25', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total (USD)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '\$${(widget.hotel.price * _selectedDateRange!.duration.inDays + 70).toStringAsFixed(0)}',
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
                        Navigator.pop(context);
                        _showSuccessDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
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
          },
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.primary,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Booking Confirmed!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your reservation at ${widget.hotel.name} was successfully booked. Enjoy your stay!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Back to Explorer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                      image: NetworkImage(widget.hotel.imageUrls[index]),
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
