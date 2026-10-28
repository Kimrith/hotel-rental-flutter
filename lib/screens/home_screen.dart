import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/auth_service.dart';
import '../services/hotel_service.dart';
import '../theme/app_theme.dart';
import '../widgets/category_selector.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/hotel_card_featured.dart';
import '../widgets/hotel_card_popular.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onFavoriteChanged;

  const HomeScreen({
    super.key,
    required this.onFavoriteChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<Hotel> _hotels = [];
  List<Hotel> _filteredHotels = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _categories = ['All', 'Cabins', 'Villas', 'Resorts', 'Lofts'];

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  Future<void> _fetchHotels({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetched = await HotelService().getHotels(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _hotels = fetched;
          _isLoading = false;
        });
        _filterListings();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _hotels = HotelService().cachedHotels;
        });
        _filterListings();
      }
    }
  }

  void _filterListings() {
    setState(() {
      _filteredHotels = _hotels.where((hotel) {
        final lower = hotel.name.toLowerCase();
        // Filter by category
        final matchesCategory = _selectedCategory == 'All' ||
            (_selectedCategory == 'Cabins' && (lower.contains('cabin') || lower.contains('pavilion') || lower.contains('cottage'))) ||
            (_selectedCategory == 'Villas' && (lower.contains('villa') || lower.contains('palace') || lower.contains('residence'))) ||
            (_selectedCategory == 'Resorts' && (lower.contains('resort') || lower.contains('seaside') || lower.contains('beach') || lower.contains('heritage') || lower.contains('boutique') || lower.contains('cliff'))) ||
            (_selectedCategory == 'Lofts' && (lower.contains('loft') || lower.contains('hotel') || lower.contains('suite')));

        // Filter by search query
        final matchesSearch = hotel.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            hotel.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            hotel.city.toLowerCase().contains(_searchQuery.toLowerCase());

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  String get _currentLocationDisplay {
    if (_hotels.isNotEmpty && _hotels.first.city.isNotEmpty) {
      return '${_hotels.first.city}, ${_hotels.first.country}';
    }
    return 'Phnom Penh, Cambodia';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _fetchHotels(forceRefresh: true),
          color: AppTheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header Row
                _buildHeader(),
                const SizedBox(height: 20),
                // Welcome title
                _buildWelcomeTitle(),
                const SizedBox(height: 24),
                // Search Bar
                CustomSearchBar(
                  onChanged: (val) {
                    _searchQuery = val;
                    _filterListings();
                  },
                ),
                const SizedBox(height: 24),
                // Categories List
                CategorySelector(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (cat) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                    _filterListings();
                  },
                ),
                const SizedBox(height: 24),

                // Main Content: Loading, Error, or Data
                if (_isLoading && _hotels.isEmpty)
                  _buildLoadingState()
                else if (_errorMessage != null && _hotels.isEmpty)
                  _buildErrorState()
                else ...[
                  // Featured Section
                  _buildFeaturedSection(),
                  const SizedBox(height: 28),
                  // Popular Deals Section
                  _buildPopularSection(),
                ],

                const SizedBox(height: 100), // Spacing for floating navbar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Connected API Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Live API',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        _currentLocationDisplay,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primary, size: 18),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // User Avatar
          GestureDetector(
            onTap: () async {
              if (AuthService().isLoggedIn) {
                await Navigator.pushNamed(context, '/personal-details');
                setState(() {});
              } else {
                await Navigator.pushNamed(context, '/login');
                setState(() {});
              }
            },
            child: Stack(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                    image: DecorationImage(
                      image: NetworkImage(
                        AuthService().avatarUrl.isNotEmpty
                            ? AuthService().avatarUrl
                            : AuthService.defaultAvatar,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Find your\nperfect sanctuary.',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.25,
          color: AppTheme.textDark,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        children: [
          Center(
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Connecting to hotel-controller...',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(
              'Could not reach hotel-controller',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Check if backend is running on localhost:8030',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _fetchHotels(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Hotels (${_filteredHotels.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              TextButton(
                onPressed: () => _fetchHotels(forceRefresh: true),
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Refresh',
                      style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _filteredHotels.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Text(
                  'No featured hotels found for this filter.',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              )
            : SizedBox(
                height: 290,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 20),
                  itemCount: _filteredHotels.length,
                  itemBuilder: (context, index) {
                    final hotel = _filteredHotels[index];
                    final tag = 'home-featured-${hotel.id}';
                    return FeaturedHotelCard(
                      hotel: hotel,
                      heroTag: tag,
                      onTap: () => _openHotelDetails(hotel, tag),
                      onFavoriteToggle: widget.onFavoriteChanged,
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildPopularSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Deals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See All',
                  style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _filteredHotels.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'No popular hotels found.',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredHotels.length,
                  itemBuilder: (context, index) {
                    final hotel = _filteredHotels[index];
                    final tag = 'home-popular-${hotel.id}';
                    return PopularHotelCard(
                      hotel: hotel,
                      heroTag: tag,
                      onTap: () => _openHotelDetails(hotel, tag),
                      onFavoriteToggle: widget.onFavoriteChanged,
                    );
                  },
                ),
        ],
      ),
    );
  }

  void _openHotelDetails(Hotel hotel, String heroTag) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => DetailScreen(hotel: hotel, heroTag: heroTag),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ).then((_) {
      // Refresh home listing state when coming back from detail screen (favoriting might have changed)
      setState(() {});
      widget.onFavoriteChanged();
    });
  }
}
