import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../theme/app_theme.dart';
import '../widgets/hotel_card_popular.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback onFavoriteChanged;

  const FavoritesScreen({
    super.key,
    required this.onFavoriteChanged,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Hotel> _savedHotels = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _savedHotels = mockHotels.where((hotel) => hotel.isFavorite).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadFavorites(); // Sync favorites when screen redraws

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Destinations'),
        elevation: 0,
      ),
      body: _savedHotels.isEmpty ? _buildEmptyState() : _buildFavoritesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_outline_rounded,
                color: AppTheme.primary,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No saved places',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore hotels, villas, and retreats, then tap the heart icon to save your favorites here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: _savedHotels.length,
      itemBuilder: (context, index) {
        final hotel = _savedHotels[index];
        final tag = 'saved-popular-${hotel.id}';
        return PopularHotelCard(
          hotel: hotel,
          heroTag: tag,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailScreen(hotel: hotel, heroTag: tag)),
            ).then((_) {
              setState(() {
                _loadFavorites();
              });
              widget.onFavoriteChanged();
            });
          },
          onFavoriteToggle: () {
            setState(() {
              _loadFavorites();
            });
            widget.onFavoriteChanged();
          },
        );
      },
    );
  }
}
