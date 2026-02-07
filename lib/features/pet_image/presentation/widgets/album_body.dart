import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/features/pet_image/presentation/models/timeline_item.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_album_notifier.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/album_timeline_view.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/pet_album_empty_state.dart';

class AlbumBody extends StatelessWidget {
  final PetAlbumState albumState;
  final List<TimelineItem> timelineItems;
  final List<String> imageUrls;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  const AlbumBody({
    super.key,
    required this.albumState,
    required this.timelineItems,
    required this.imageUrls,
    required this.onRefresh,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (albumState.isLoading && albumState.images.isEmpty) {
      return _buildLoadingState(context);
    }

    if (albumState.isEmpty) {
      return const PetAlbumEmptyState();
    }

    return Container(
      color: Colors.white.withValues(alpha: 0.08),
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

  Widget _buildLoadingState(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.1,
      child: Center(
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryPink.withValues(alpha: 0.05),
          ),
        ),
      ),
    );
  }
}
