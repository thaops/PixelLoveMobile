import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/utils/image_cache_helper.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/pet_image/presentation/models/timeline_item.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/album_body.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/album_camera_button.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_album_header.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';
import 'package:pixel_love/routes/app_routes.dart';

class PetAlbumScreen extends ConsumerWidget {
  const PetAlbumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ImageCacheHelper.initialize();
    });

    final albumState = ref.watch(petAlbumNotifierProvider);
    final albumNotifier = ref.read(petAlbumNotifierProvider.notifier);
    final timelineItems = albumState.isEmpty
        ? <TimelineItem>[]
        : albumNotifier.buildTimelineItems();
    final imageUrls = _collectImageUrls(timelineItems);

    final canPop = context.canPop();

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !canPop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go(AppRoutes.home);
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LoveBackground(
          child: Stack(
            children: [
              AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.transparent,
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      PetAlbumHeader(canPop: canPop, isSwipeMode: false),
                      Expanded(
                        child: AlbumBody(
                          albumState: albumState,
                          timelineItems: timelineItems,
                          imageUrls: imageUrls,
                          onRefresh: albumNotifier.refresh,
                          onLoadMore: albumNotifier.loadMore,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Positioned(
                bottom: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24, right: 24),
                    child: AlbumCameraButton(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _collectImageUrls(List<TimelineItem> items) {
    final urls = <String>[];
    for (final item in items) {
      if (item is ImageItem) {
        urls.add(item.image.imageUrl);
      } else if (item is ComboItem) {
        urls.addAll(item.images.map((img) => img.imageUrl));
      }
    }
    return urls;
  }
}
