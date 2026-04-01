import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/watch_together/domain/entities/video_items.dart';
import 'package:pixel_love/features/watch_together/providers/watch_together_providers.dart';

class WtQueueList extends ConsumerWidget {
  const WtQueueList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(
      watchTogetherNotifierProvider.select(
        (s) => s.roomState?.videoItems ?? <VideoItems>[],
      ),
    );
    final currentId = ref.watch(
      watchTogetherNotifierProvider.select((s) => s.roomState?.currentId),
    );

    if (items.isEmpty) {
      return const Center(child: Text('Playlist trống'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _QueueItem(
          key: ValueKey(item.id),
          item: item,
          isActive: item.id == currentId,
        );
      },
    );
  }
}

// Tách widget riêng để chỉ rebuild item nào thay đổi
class _QueueItem extends ConsumerWidget {
  final VideoItems item;
  final bool isActive;

  const _QueueItem({
    super.key,
    required this.item,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      tileColor: isActive
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4)
          : null,
      leading: item.thumbnail.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                item.thumbnail,
                width: 60,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.video_library),
              ),
            )
          : const Icon(Icons.video_library),
      title: Text(
        item.title.isNotEmpty ? item.title : item.videoId,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18),
        onPressed: () =>
            ref.read(watchTogetherNotifierProvider.notifier).removeVideo(item.id),
      ),
    );
  }
}
