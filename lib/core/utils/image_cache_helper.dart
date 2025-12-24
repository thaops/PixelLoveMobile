import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Helper class để quản lý cache và preload ảnh
class ImageCacheHelper {
  static const int _maxCacheSize = 200; // Tăng số lượng ảnh cache trong memory
  static const int _maxCacheBytes = 200 * 1024 * 1024; // 200MB

  /// Khởi tạo và cấu hình ImageCache
  static void initialize() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = _maxCacheSize;
    imageCache.maximumSizeBytes = _maxCacheBytes;
  }

  /// Preload ảnh vào memory cache với BuildContext
  /// Trả về true nếu preload thành công hoặc đã có trong cache
  static Future<bool> preloadImage(String imageUrl, BuildContext context) async {
    try {
      final imageProvider = CachedNetworkImageProvider(
        imageUrl);
      
      // Preload vào memory (precacheImage sẽ tự kiểm tra cache)
      await precacheImage(imageProvider, context);
      return true;
    } catch (e) {
      // Nếu preload thất bại, vẫn trả về false
      // Ảnh sẽ được load khi hiển thị
      return false;
    }
  }

  /// Preload nhiều ảnh cùng lúc (batch)
  static Future<void> preloadImages(
    List<String> imageUrls,
    BuildContext context,
  ) async {
    // Preload từng ảnh nhưng không đợi tất cả hoàn thành
    // Để tránh block UI thread
    for (final url in imageUrls) {
      preloadImage(url, context).ignore();
    }
  }

  /// Preload ảnh cho các item sắp hiển thị (visible + next few items)
  static void preloadUpcomingImages({
    required List<String> imageUrls,
    required int currentIndex,
    required BuildContext context,
    int lookAhead = 3, // Preload 3 ảnh tiếp theo
  }) {
    final startIndex = currentIndex;
    final endIndex = (currentIndex + lookAhead).clamp(0, imageUrls.length);
    
    if (startIndex < endIndex) {
      final urlsToPreload = imageUrls.sublist(startIndex, endIndex);
      preloadImages(urlsToPreload, context);
    }
  }
}

