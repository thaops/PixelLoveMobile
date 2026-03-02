import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/audio_player/providers/audio_providers.dart';
import 'package:pixel_love/features/audio_player/presentation/widgets/player_header.dart';
import 'package:pixel_love/features/audio_player/presentation/widgets/player_artwork.dart';
import 'package:pixel_love/features/audio_player/presentation/widgets/player_controls.dart';
import 'package:pixel_love/features/audio_player/presentation/widgets/player_progress_bar.dart';
import 'package:pixel_love/features/audio_player/presentation/widgets/queue_bottom_sheet.dart';
import 'package:pixel_love/features/audio_player/presentation/widgets/add_song_bottom_sheet.dart';
import 'package:pixel_love/features/user/providers/user_providers.dart';

class AudioPlayerScreen extends ConsumerWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioPlayerNotifierProvider);
    final notifier = ref.read(audioPlayerNotifierProvider.notifier);
    final currentUser = ref.watch(userNotifierProvider).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Stack(
        children: [
          const _MeshBackground(),
          if (state.currentTrack != null)
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  key: ValueKey(state.currentTrack!.id),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(state.currentTrack!.thumbnail),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.4),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                const PlayerHeader(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Adjust spacing and sizes based on available height
                      final isSmallDevice = constraints.maxHeight < 600;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 1. Artwork - Responsive Size
                            Flexible(
                              flex: isSmallDevice ? 6 : 8,
                              child: GestureDetector(
                                onHorizontalDragEnd: (details) {
                                  if (details.primaryVelocity! < -500) {
                                    notifier.next();
                                  } else if (details.primaryVelocity! > 500) {
                                    notifier.previous();
                                  }
                                },
                                child: PlayerArtwork(
                                  track: state.currentTrack,
                                  isPartnerOnline: state.isPartnerOnline,
                                  meAvatar: currentUser?.avatar,
                                  partnerAvatar: state.partnerAvatar,
                                  meLabel:
                                      (currentUser?.name != null &&
                                          currentUser!.name!.isNotEmpty)
                                      ? currentUser.name![0].toUpperCase()
                                      : 'M',
                                  partnerLabel:
                                      (state.partnerName != null &&
                                          state.partnerName!.isNotEmpty)
                                      ? state.partnerName![0].toUpperCase()
                                      : 'V',
                                ),
                              ),
                            ),

                            // 2. Info
                            Flexible(
                              flex: isSmallDevice ? 2 : 3,
                              child: _buildSongInfo(state, isSmallDevice),
                            ),

                            // 3. Progress + Controls - Ensuring they are always visible
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: PlayerProgressBar(
                                    currentTime: state.currentTime,
                                    totalTime:
                                        state.currentTrack?.duration ?? 0,
                                    onSeek: (time) => notifier.seek(time),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                PlayerControls(
                                  isPlaying: state.isPlaying,
                                  isLoading: state.isLoading,
                                  onPlayPause: () {
                                    if (state.isPlaying) {
                                      notifier.pauseTrack();
                                    } else if (state.currentTrack != null) {
                                      notifier.playTrack(
                                        state.currentTrack!.id,
                                      );
                                    }
                                  },
                                  onNext: () => notifier.next(),
                                  onPrevious: () => notifier.previous(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                _buildQueuePreview(context, state, notifier),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSongBottomSheet(context, notifier),
        backgroundColor: Colors.white.withOpacity(0.1),
        elevation: 0,
        mini: true, // Mini FAB to save space on small devices
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSongInfo(state, bool isSmall) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            state.currentTrack?.title ?? "Chưa có bài hát",
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 20 : 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmall ? 4 : 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sync, color: Colors.pinkAccent, size: 12),
                const SizedBox(width: 4),
                Text(
                  'SYNCING',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueuePreview(BuildContext context, state, notifier) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              _showQueueBottomSheet(context, state, notifier);
            }
          },
          onTap: () => _showQueueBottomSheet(context, state, notifier),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 12,
              bottom: 20,
            ), // Reduced bottom padding
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: const Border(top: BorderSide(color: Colors.white10)),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.playlist_play,
                        color: Colors.white54,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.queue.isNotEmpty
                              ? 'Next: ${state.queue.first.title}'
                              : 'Up Next: Empty Queue',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQueueBottomSheet(context, state, notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QueueBottomSheet(
        currentTrack: state.currentTrack,
        queue: state.queue,
        onPlay: (id) => notifier.playTrack(id),
        onDelete: (id) => notifier.removeTrack(id),
      ),
    );
  }

  void _showAddSongBottomSheet(context, notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          AddSongBottomSheet(onAdd: (url) => notifier.addTrack(url)),
    );
  }
}

class _MeshBackground extends StatelessWidget {
  const _MeshBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.pinkAccent.withOpacity(0.15),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurple.withOpacity(0.2),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }
}
