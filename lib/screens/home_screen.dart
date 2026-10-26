import 'package:flutter/material.dart';
import '../../models/hotel.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_selector.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/hotel_card_featured.dart';
import '../../widgets/hotel_card_popular.dart';
import '../details/detail_screen.dart';

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
  List<Hotel> _filteredHotels = List.from(mockHotels);

  final List<String> _categories = ['All', 'Cabins', 'Villas', 'Resorts', 'Lofts'];

  void _filterListings() {
    setState(() {
      _filteredHotels = mockHotels.where((hotel) {
        // Filter by category
        final matchesCategory = _selectedCategory == 'All' ||
            (_selectedCategory == 'Cabins' && hotel.name.toLowerCase().contains('pavilion')) ||
            (_selectedCategory == 'Villas' && hotel.name.toLowerCase().contains('villa')) ||
            (_selectedCategory == 'Resorts' && (hotel.name.toLowerCase().contains('residence') || hotel.name.toLowerCase().contains('cliff'))) ||
            (_selectedCategory == 'Lofts' && hotel.name.toLowerCase().contains('loft'));

        // Filter by search query
        final matchesSearch = hotel.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            hotel.location.toLowerCase().contains(_searchQuery.toLowerCase());

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header Row
              _buildHeader(),
              const SizedBox(height: 24),
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
              // Featured Section
              _buildFeaturedSection(),
              const SizedBox(height: 28),
              // Popular Deals Section
              _buildPopularSection(),
              const SizedBox(height: 100), // Spacing for floating navbar
            ],
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
                  Text(
                    'Current Location',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Stockholm, SE',
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
          // User Avatar / Notification
          Stack(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
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
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
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
                'Featured Hotels',
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
        ),
        const SizedBox(height: 8),
        _filteredHotels.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Text('No featured hotels found for this filter.'),
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
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No popular hotels found.'),
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
