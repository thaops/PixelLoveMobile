import 'package:flutter/material.dart';
import 'package:pixel_love/core/utils/image_cache_helper.dart';
import 'package:pixel_love/features/pet_image/presentation/models/timeline_item.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_album_notifier.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/timeline_items/combo_item.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/timeline_items/image_bubble.dart';
import 'package:pixel_love/features/pet_image/presentation/widgets/timeline_items/time_header.dart';

class AlbumTimelineView extends StatefulWidget {
  final List<String> imageUrls;
  final List<TimelineItem> timelineItems;
  final PetAlbumState albumState;
  final VoidCallback onLoadMore;

  const AlbumTimelineView({
    super.key,
    required this.imageUrls,
    required this.timelineItems,
    required this.albumState,
    required this.onLoadMore,
  });

  @override
  State<AlbumTimelineView> createState() => _AlbumTimelineViewState();
}

class _AlbumTimelineViewState extends State<AlbumTimelineView> {
  final ScrollController _scrollController = ScrollController();
  int _lastPreloadedIndex = -1;
  List<String> _previousImageUrls = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _previousImageUrls = List.from(widget.imageUrls);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.imageUrls.isEmpty) return;
      ImageCacheHelper.preloadUpcomingImages(
        imageUrls: widget.imageUrls,
        currentIndex: 0,
        context: context,
        lookAhead: 5,
      );
      _lastPreloadedIndex = 4;
    });
  }

  @override
  void didUpdateWidget(covariant AlbumTimelineView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.imageUrls.length > _previousImageUrls.length) {
      final newUrls = widget.imageUrls
          .where((url) => !_previousImageUrls.contains(url))
          .toList();

      if (newUrls.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ImageCacheHelper.preloadImages(newUrls, context);
          }
        });
      }
    }
    _previousImageUrls = List.from(widget.imageUrls);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final scrollOffset = _scrollController.position.pixels;
    final estimatedIndex = (scrollOffset / 250).floor();

    if (estimatedIndex > _lastPreloadedIndex &&
        estimatedIndex < widget.imageUrls.length) {
      const lookAhead = 3;
      final startIndex = (_lastPreloadedIndex + 1)
          .clamp(0, widget.imageUrls.length);
      final endIndex =
          (estimatedIndex + lookAhead).clamp(0, widget.imageUrls.length);

      if (startIndex < endIndex) {
        ImageCacheHelper.preloadUpcomingImages(
          imageUrls: widget.imageUrls,
          currentIndex: startIndex,
          context: context,
          lookAhead: endIndex - startIndex,
        );
        _lastPreloadedIndex = endIndex - 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < widget.timelineItems.length) {
                  final item = widget.timelineItems[index];
                  final nextItem = index < widget.timelineItems.length - 1
                      ? widget.timelineItems[index + 1]
                      : null;

                  if (index > _lastPreloadedIndex &&
                      index < widget.imageUrls.length) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      final imageIndex =
                          _getImageIndexForTimelineIndex(index);
                      if (imageIndex >= 0 &&
                          imageIndex < widget.imageUrls.length) {
                        ImageCacheHelper.preloadImage(
                          widget.imageUrls[imageIndex],
                          context,
                        );
                      }
                    });
                  }

                  return TimelineItemBuilder.build(
                    context: context,
                    item: item,
                    nextItem: nextItem,
                  );
                }

                if (widget.albumState.hasMore) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onLoadMore();
                  });
                  return const _LoadingMoreIndicator();
                }
                return const SizedBox.shrink();
              },
              childCount:
                  widget.timelineItems.length +
                  (widget.albumState.hasMore ? 1 : 0),
            ),
          ),
        ),
        if (widget.albumState.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  int _getImageIndexForTimelineIndex(int timelineIndex) {
    int imageCount = 0;
    for (int i = 0; i <= timelineIndex && i < widget.timelineItems.length; i++) {
      final item = widget.timelineItems[i];
      if (item is ImageItem) {
        if (i == timelineIndex) return imageCount;
        imageCount++;
      } else if (item is ComboItem) {
        if (i == timelineIndex) return imageCount;
        imageCount += 2;
      }
    }
    return -1;
  }
}

class TimelineItemBuilder {
  const TimelineItemBuilder._();

  static Widget build({
    required BuildContext context,
    required TimelineItem item,
    TimelineItem? nextItem,
  }) {
    if (item is TimeHeader) {
      return TimeHeaderWidget(header: item);
    }
    if (item is ImageItem) {
      final hasNext = nextItem != null && nextItem is! TimeHeader;
      return ImageBubble(item: item, hasNext: hasNext);
    }
    if (item is ComboItem) {
      final hasNext = nextItem != null && nextItem is! TimeHeader;
      return ComboItemWidget(combo: item, hasNext: hasNext);
    }
    return const SizedBox.shrink();
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}

