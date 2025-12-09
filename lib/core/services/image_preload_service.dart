import 'dart:async';
import 'package:flutter/material.dart';

class ImagePreloadService {
  static final Set<String> _preloadedImages = {};
  
  // Preload single image using ImageStream
  static Future<void> preloadImage(String imageUrl) async {
    if (_preloadedImages.contains(imageUrl)) {
      print('⏭️ Already preloaded: $imageUrl');
      return;
    }
    
    try {
      final imageProvider = NetworkImage(imageUrl);
      final imageStream = imageProvider.resolve(const ImageConfiguration());
      
      final completer = Completer<void>();
      late ImageStreamListener listener;
      
      listener = ImageStreamListener(
        (ImageInfo imageInfo, bool synchronousCall) {
          _preloadedImages.add(imageUrl);
          imageStream.removeListener(listener);
          completer.complete();
          print('✅ Preloaded: $imageUrl');
        },
        onError: (exception, stackTrace) {
          imageStream.removeListener(listener);
          completer.complete();
          print('❌ Preload failed: $imageUrl - $exception');
        },
      );
      
      imageStream.addListener(listener);
      await completer.future;
    } catch (e) {
      print('❌ Preload exception: $imageUrl - $e');
    }
  }
  
  // Preload multiple images in parallel
  static Future<void> preloadImages(List<String> imageUrls) async {
    if (imageUrls.isEmpty) return;
    
    print('🚀 Preloading ${imageUrls.length} images...');
    await Future.wait(
      imageUrls.map((url) => preloadImage(url)),
      eagerError: false, // Continue even if some fail
    );
    print('✅ Preload complete: ${_preloadedImages.length}/${imageUrls.length} images');
  }
  
  // Check if image is preloaded
  static bool isPreloaded(String imageUrl) {
    return _preloadedImages.contains(imageUrl);
  }
  
  // Clear preloaded images
  static void clearCache() {
    _preloadedImages.clear();
    print('🗑️ Image preload cache cleared');
  }
}

