import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/watch_together/providers/watch_together_providers.dart';

class WtControls extends ConsumerWidget {
  const WtControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(
      watchTogetherNotifierProvider.select((s) => s.roomState?.isPlaying ?? false),
    );
    final hasVideo = ref.watch(
      watchTogetherNotifierProvider.select((s) => s.roomState?.videoId != null),
    );
    final notifier = ref.read(watchTogetherNotifierProvider.notifier);

    if (!hasVideo) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.skip_next),
            tooltip: 'Next',
            onPressed: notifier.nextVideo,
          ),
          IconButton(
            iconSize: 40,
            icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
            onPressed: () async {
              // Đọc controller từ provider để lấy currentTime chính xác
              final ctrl = ref.read(ytControllerProvider);
              final time = ctrl != null ? await ctrl.currentTime : 0.0;
              notifier.sendPlayPause(
                currentIsPlaying: isPlaying,
                time: time,
              );
            },
          ),
        ],
      ),
    );
  }
}
