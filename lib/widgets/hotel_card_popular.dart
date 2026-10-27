import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/auth_service.dart';
import '../services/hotel_service.dart';
import '../theme/app_theme.dart';
import 'app_image.dart';

class PopularHotelCard extends StatefulWidget {
  final Hotel hotel;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  final String? heroTag;

  const PopularHotelCard({
    super.key,
    required this.hotel,
    required this.onTap,
    this.onFavoriteToggle,
    this.heroTag,
  });

  @override
  State<PopularHotelCard> createState() => _PopularHotelCardState();
}

class _PopularHotelCardState extends State<PopularHotelCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 110,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Row(
          children: [
            // Left Image
            SizedBox(
              width: 94,
              height: 94,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Hero(
                  tag: widget.heroTag ?? 'hotel-img-popular-${widget.hotel.id}',
                  child: AppImage(
                    imageUrl: widget.hotel.imageUrl,
                    height: 94,
                    width: 94,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Right info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.hotel.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Favorite
                      GestureDetector(
                        onTap: () async {
                          if (!await AuthService().requireAuth(context, action: 'save to favorites')) {
                            return;
                          }
                          await HotelService().toggleFavorite(widget.hotel);
                          if (mounted) {
                            setState(() {});
                          }
                          if (widget.onFavoriteToggle != null) {
                            widget.onFavoriteToggle!();
                          }
                        },
                        child: Icon(
                          widget.hotel.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: widget.hotel.isFavorite ? Colors.red : AppTheme.textMuted,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.hotel.location,
                          style: TextStyle(
                            fontSize: 12,
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
                      ),
                      const SizedBox(width: 4),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: AppTheme.accent, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            widget.hotel.rating.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
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
