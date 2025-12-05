import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Optimized image caching service for better performance
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  // Custom cache manager for images
  static final CacheManager _imageCacheManager = CacheManager(
    Config(
      'image_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: 'image_cache.db'),
    ),
  );

  /// Get cached network image widget with optimizations
  static Widget cachedImage({
    required String imageUrl,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        cacheManager: _imageCacheManager,
        placeholder: (context, url) => placeholder ??
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        errorWidget: (context, url, error) => errorWidget ??
          Container(
            color: Colors.grey[300],
            child: const Icon(Icons.error_outline, color: Colors.grey),
          ),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
        memCacheWidth: width?.toInt(),
        memCacheHeight: height?.toInt(),
        maxWidthDiskCache: 1920,
        maxHeightDiskCache: 1080,
      ),
    );
  }

  /// Preload image into cache
  static Future<void> preloadImage(String imageUrl) async {
    try {
      await _imageCacheManager.getSingleFile(imageUrl);
    } catch (e) {
      debugPrint('Error preloading image: $e');
    }
  }

  /// Preload multiple images
  static Future<void> preloadImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      unawaited(preloadImage(url));
    }
  }

  /// Clear image cache
  static Future<void> clearCache() async {
    await _imageCacheManager.emptyCache();
  }

  /// Get cache size
  static Future<int> getCacheSize() async {
    return await _imageCacheManager.getTotalSize();
  }
}

void unawaited(Future<void> future) {}
