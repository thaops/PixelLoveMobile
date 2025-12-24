import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/utils/image_cache_helper.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/pet_image/presentation/models/timeline_item.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_album_notifier.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/album_timeline_view.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_album_empty_state.dart';
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
    final timelineItems =
        albumState.isEmpty ? <TimelineItem>[] : albumNotifier.buildTimelineItems();
    final imageUrls = _collectImageUrls(timelineItems);

    final canPop = context.canPop();

    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (!didPop && !canPop) {
          // If cannot pop, navigate to home instead of exiting app
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
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  PetAlbumHeader(canPop: canPop),
                  Expanded(
                    child: _AlbumBody(
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

class _AlbumBody extends StatelessWidget {
  final PetAlbumState albumState;
  final List<TimelineItem> timelineItems;
  final List<String> imageUrls;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  const _AlbumBody({
    required this.albumState,
    required this.timelineItems,
    required this.imageUrls,
    required this.onRefresh,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (albumState.isLoading && albumState.images.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (albumState.isEmpty) {
      return const PetAlbumEmptyState();
    }

    return Container(
      color: Colors.white.withOpacity(0.08),
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.primaryPink,
        child: AlbumTimelineView(
          imageUrls: imageUrls,
          timelineItems: timelineItems,
          albumState: albumState,
          onLoadMore: onLoadMore,
        ),
      ),
    );
  }
}
