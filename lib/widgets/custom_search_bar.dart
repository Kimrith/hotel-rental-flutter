import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterPressed;

  const CustomSearchBar({
    super.key,
    this.onChanged,
    this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: AppTheme.softShadow,
              ),
              child: TextField(
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Search hotels, villas, cabins...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
                  hintStyle: TextStyle(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.cardBg,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onFilterPressed ?? () => _showFilterBottomSheet(context),
            child: Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.softShadow,
              ),
              child: Icon(
                Icons.tune_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const FilterBottomSheet();
      },
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  double _priceRange = 350.0;
  double _minRating = 4.0;
  List<String> selectedAmenities = [];

  final List<String> amenities = ['Pool', 'Wifi', 'Spa', 'AC', 'Gym', 'Breakfast'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _priceRange = 350.0;
                    _minRating = 4.0;
                    selectedAmenities.clear();
                  });
                },
                child: Text(
                  'Reset All',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
          Divider(color: AppTheme.border),
          const SizedBox(height: 16),
          // Price filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Max Price per Night',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                '\$${_priceRange.round()}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primary,
              inactiveTrackColor: AppTheme.border,
              thumbColor: AppTheme.primary,
              overlayColor: AppTheme.primary.withOpacity(0.2),
              valueIndicatorColor: AppTheme.primary,
            ),
            child: Slider(
              value: _priceRange,
              min: 50,
              max: 1000,
              divisions: 19,
              label: '\$${_priceRange.round()}',
              onChanged: (value) {
                setState(() {
                  _priceRange = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          // Star ratings
          Text(
            'Minimum Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final starVal = index + 1.0;
              final isSelected = _minRating == starVal;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _minRating = starVal;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryLight : AppTheme.cardBg,
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.border,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: isSelected ? AppTheme.accent : AppTheme.textMuted,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${index + 1}+',
                        style: TextStyle(
                          color: isSelected ? AppTheme.primary : AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          // Amenities
          Text(
            'Amenities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amenities.map((amenity) {
              final isSelected = selectedAmenities.contains(amenity);
              return FilterChip(
                label: Text(amenity),
                selected: isSelected,
                selectedColor: AppTheme.primaryLight,
                checkmarkColor: AppTheme.primary,
                backgroundColor: AppTheme.cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primary : AppTheme.border,
                  ),
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedAmenities.add(amenity);
                    } else {
                      selectedAmenities.remove(amenity);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
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
                'Apply Filters',
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
