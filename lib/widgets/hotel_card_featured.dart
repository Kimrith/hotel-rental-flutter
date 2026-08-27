import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../theme/app_theme.dart';

class FeaturedHotelCard extends StatefulWidget {
  final Hotel hotel;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  final String? heroTag;

  const FeaturedHotelCard({
    super.key,
    required this.hotel,
    required this.onTap,
    this.onFavoriteToggle,
    this.heroTag,
  });

  @override
  State<FeaturedHotelCard> createState() => _FeaturedHotelCardState();
}

class _FeaturedHotelCardState extends State<FeaturedHotelCard> with SingleTickerProviderStateMixin {
  late AnimationController _favController;
  late Animation<double> _favScale;

  @override
  void initState() {
    super.initState();
    _favController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _favScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _favController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _favController.dispose();
    super.dispose();
  }

  void _handleFavoriteTap() {
    setState(() {
      widget.hotel.isFavorite = !widget.hotel.isFavorite;
    });
    _favController.forward().then((value) => _favController.reverse());
    if (widget.onFavoriteToggle != null) {
      widget.onFavoriteToggle!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Hero(
                    tag: widget.heroTag ?? 'hotel-img-${widget.hotel.id}',
                    child: Image.network(
                      widget.hotel.imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 160,
                        color: AppTheme.primaryLight,
                        child: Icon(Icons.broken_image, color: AppTheme.primary),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 160,
                          color: AppTheme.border,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Rating overlay
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded, color: AppTheme.accent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.hotel.rating.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Favorite Button overlay
                Positioned(
                  top: 12,
                  right: 12,
                  child: ScaleTransition(
                    scale: _favScale,
                    child: GestureDetector(
                      onTap: _handleFavoriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.hotel.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: widget.hotel.isFavorite ? Colors.red : AppTheme.textMuted,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info block
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hotel.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.hotel.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            text: '\$${widget.hotel.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                            children: [
                              TextSpan(
                                text: ' / night',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.hotel.guests} Rooms',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
