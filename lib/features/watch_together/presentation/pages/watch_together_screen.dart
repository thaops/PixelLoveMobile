import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/watch_together/presentation/notifiers/watch_together_notifier.dart';
import 'package:pixel_love/features/watch_together/presentation/widgets/wt_add_video_bar.dart';
import 'package:pixel_love/features/watch_together/presentation/widgets/wt_controls.dart';
import 'package:pixel_love/features/watch_together/presentation/widgets/wt_player.dart';
import 'package:pixel_love/features/watch_together/presentation/widgets/wt_queue_list.dart';
import 'package:pixel_love/features/watch_together/providers/watch_together_providers.dart';

class WatchTogetherScreen extends ConsumerWidget {
  const WatchTogetherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      watchTogetherNotifierProvider.select((s) => s.isLoading),
    );
    final hasRoom = ref.watch(
      watchTogetherNotifierProvider.select((s) => s.roomState != null),
    );

    ref.listen(
      watchTogetherNotifierProvider.select((s) => s.errorMessage),
      (_, error) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
          ref.read(watchTogetherNotifierProvider.notifier).clearError();
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch Together'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: ref.read(watchTogetherNotifierProvider.notifier).loadState,
          ),
        ],
      ),
      body: isLoading && !hasRoom
          ? const Center(child: CircularProgressIndicator())
          : const Column(
              children: [
                WtPlayer(),
                WtControls(),
                WtAddVideoBar(),
                Expanded(child: WtQueueList()),
              ],
            ),
    );
  }
}
