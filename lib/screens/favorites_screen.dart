import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hotel_card_popular.dart';
import 'detail_screen.dart';

import '../services/favorite_service.dart';
import '../services/hotel_service.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites(fetchLive: true);
  }

  Future<void> _loadFavorites({bool fetchLive = false}) async {
    if (!AuthService().isLoggedIn) {
      if (mounted) {
        setState(() {
          _savedHotels = [];
          _isLoading = false;
        });
      }
      return;
    }

    if (fetchLive) {
      if (mounted) setState(() => _isLoading = true);
      try {
        await FavoriteService().getFavorites();
        FavoriteService().syncHotels(HotelService().cachedHotels);
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _savedHotels = HotelService().cachedHotels.where((hotel) => hotel.isFavorite).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthService().authStateNotifier,
      builder: (context, isLoggedIn, _) {
        if (!isLoggedIn) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Destinations'),
              elevation: 0,
            ),
            body: _buildGuestState(),
          );
        }

        final activeFavorites = HotelService().cachedHotels.where((hotel) => hotel.isFavorite).toList();
        final displayList = activeFavorites.isNotEmpty ? activeFavorites : _savedHotels;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Saved Destinations'),
            elevation: 0,
          ),
          body: RefreshIndicator(
            onRefresh: () => _loadFavorites(fetchLive: true),
            color: AppTheme.primary,
            child: _isLoading && displayList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : displayList.isEmpty
                    ? _buildEmptyState()
                    : _buildFavoritesList(displayList),
          ),
        );
      },
    );
  }

  Widget _buildGuestState() {
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
                Icons.lock_outline_rounded,
                color: AppTheme.primary,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sign in to see favorites',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Log in or create an account to view and synchronize your saved hotels.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final success = await AuthService().requireAuth(context, action: 'access your saved favorites');
                  if (success) {
                    _loadFavorites(fetchLive: true);
                  }
                },
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('Log in / Register', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildFavoritesList(List<Hotel> hotels) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: hotels.length,
      itemBuilder: (context, index) {
        final hotel = hotels[index];
        final tag = 'saved-popular-${hotel.id}';
        return PopularHotelCard(
          hotel: hotel,
          heroTag: tag,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailScreen(hotel: hotel, heroTag: tag)),
            ).then((_) {
              _loadFavorites();
              widget.onFavoriteChanged();
            });
          },
          onFavoriteToggle: () {
            _loadFavorites();
            widget.onFavoriteChanged();
          },
        );
      },
    );
  }
}
