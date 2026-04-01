import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:pixel_love/features/watch_together/presentation/notifiers/watch_together_notifier.dart';
import 'package:pixel_love/features/watch_together/providers/watch_together_providers.dart';

class WtPlayer extends ConsumerStatefulWidget {
  const WtPlayer({super.key});

  @override
  ConsumerState<WtPlayer> createState() => _WtPlayerState();
}

class _WtPlayerState extends ConsumerState<WtPlayer> {
  YoutubePlayerController? _ctrl;
  String? _lastVideoId;
  bool _listenerAttached = false;

  @override
  void dispose() {
    _ctrl?.close();
    ref.read(ytControllerProvider.notifier).clear();
    super.dispose();
  }

  Future<void> _applySync() async {
    final ctrl = _ctrl;
    if (ctrl == null) return;
    final uiState = ref.read(watchTogetherNotifierProvider);
    final seekTo = uiState.pendingSeekTo;
    final isPlaying = uiState.roomState?.isPlaying ?? false;

    if (seekTo != null) {
      await ctrl.seekTo(seconds: seekTo, allowSeekAhead: true);
      ref.read(watchTogetherNotifierProvider.notifier).clearPendingSeek();
    }

    final ps = await ctrl.playerState;
    if (isPlaying && ps != PlayerState.playing) {
      await ctrl.playVideo();
    } else if (!isPlaying && ps == PlayerState.playing) {
      await ctrl.pauseVideo();
    }
  }

  void _attachListener(YoutubePlayerController ctrl) {
    if (_listenerAttached) return;
    _listenerAttached = true;
    ctrl.listen((event) {
      if (event.playerState == PlayerState.ended) {
        ref.read(watchTogetherNotifierProvider.notifier).onVideoEnded();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoId = ref.watch(
      watchTogetherNotifierProvider.select((s) => s.roomState?.videoId),
    );

    // Tạo mới controller chỉ khi videoId thay đổi
    if (videoId != null && videoId != _lastVideoId) {
      _ctrl?.close();
      _lastVideoId = videoId;
      _listenerAttached = false;
      _ctrl = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          mute: false,
        ),
      );
      // Expose controller để WtControls có thể dùng
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(ytControllerProvider.notifier).setController(_ctrl!);
      });
    }

    // Lắng nghe pendingSeekTo để sync player với server
    ref.listen(
      watchTogetherNotifierProvider.select((s) => s.pendingSeekTo),
      (_, seekTo) {
        if (seekTo != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _applySync());
        }
      },
    );

    if (_ctrl == null || videoId == null) {
      return Container(
        height: 220,
        color: Colors.black,
        child: const Center(
          child: Text('Chưa có video', style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    _attachListener(_ctrl!);

    return YoutubePlayer(
      controller: _ctrl!,
      aspectRatio: 16 / 9,
    );
  }
}
