import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pixel_love/core/utils/image_loader_utils.dart';
import 'package:pixel_love/features/fridge/domain/entities/fridge.dart';

class FridgeController {
  final WidgetRef ref;
  final BuildContext context;
  final VoidCallback onStateChanged;

  bool backgroundLoaded = false;
  bool isPreloading = false;
  String? lastBackgroundUrl;

  FridgeController({
    required this.ref,
    required this.context,
    required this.onStateChanged,
  });

  bool shouldResetPreload(String backgroundUrl) {
    if (lastBackgroundUrl != backgroundUrl) {
      lastBackgroundUrl = backgroundUrl;
      backgroundLoaded = false;
      isPreloading = false;
      return true;
    }
    return false;
  }

  Future<void> preloadAssets(Fridge fridgeData) async {
    if (isPreloading || backgroundLoaded) return;

    isPreloading = true;
    onStateChanged();

    try {
      final List<Future<void>> preloadFutures = [];

      final bgUrl = fridgeData.background.imageUrl;
      if (bgUrl.isNotEmpty) {
        final imageProvider = NetworkImage(bgUrl);
        preloadFutures.add(
          ImageLoaderUtils.waitForImageToRender(
            imageProvider,
            context,
          ).timeout(const Duration(seconds: 10), onTimeout: () => false),
        );
      }

      for (final note in fridgeData.notes) {
        if (note.frameImageUrl.isEmpty) continue;
        final provider = CachedNetworkImageProvider(note.frameImageUrl);
        preloadFutures.add(
          precacheImage(
            provider,
            context,
          ).timeout(const Duration(seconds: 8), onTimeout: () {}),
        );
      }

      await Future.wait(preloadFutures, eagerError: false);
    } catch (_) {
    } finally {
      isPreloading = false;
      backgroundLoaded = true;
      onStateChanged();
    }
  }

  void onLoadError() {
    backgroundLoaded = true;
    onStateChanged();
  }
}
