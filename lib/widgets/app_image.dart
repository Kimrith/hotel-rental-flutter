import 'package:flutter/material.dart';
import '../models/hotel.dart';

class AppImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  /// Returns AssetImage for local assets or NetworkImage for web URLs
  static ImageProvider provider(String url) {
    if (url.startsWith('assets/')) {
      return AssetImage(url);
    }
    return NetworkImage(url);
  }

  Widget _buildPlaceholderBox() {
    final iconSize = (width != null && height != null)
        ? (width! < height! ? width! * 0.35 : height! * 0.35).clamp(16.0, 48.0)
        : 26.0;

    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFE2E8F0),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.apartment_rounded,
          color: const Color(0xFF94A3B8),
          size: iconSize,
        ),
      ),
    );
  }

  Widget _fallbackWidget() {
    return Image.asset(
      Hotel.defaultAssetImage,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        if (Hotel.defaultAssetImage != 'assets/images/default_img.png') {
          return Image.asset(
            'assets/images/default_img.png',
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (ctx, err, stack) => _buildPlaceholderBox(),
          );
        }
        return _buildPlaceholderBox();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = _buildContent(context);

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: ClipRect(child: imageWidget),
      );
    }

    return imageWidget;
  }

  Widget _buildContent(BuildContext context) {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) {
      return _fallbackWidget();
    }

    if (trimmed.startsWith('assets/')) {
      return Image.asset(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _fallbackWidget(),
      );
    }

    return Image.network(
      trimmed,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            Container(
              width: width,
              height: height,
              color: const Color(0xFFF1F5F9),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) => _fallbackWidget(),
    );
  }
}

