import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/radio/domain/entities/voice.dart';
import 'package:pixel_love/features/radio/presentation/notifiers/radio_notifier.dart';
import 'package:pixel_love/features/radio/presentation/widgets/voice_record_bottom_sheet.dart';
import 'package:pixel_love/features/radio/providers/radio_providers.dart';
import 'package:pixel_love/routes/app_routes.dart';

class RadioScreen extends ConsumerWidget {
  const RadioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radioState = ref.watch(radioNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: const Text(
          'Voice Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: _buildVoiceFab(context),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: LoveBackground(child: _buildBody(context, ref, radioState)),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, RadioState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(radioNotifierProvider.notifier).refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.voices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.radio, size: 80, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'Chưa có voice message nào',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.voices.length,
              itemBuilder: (context, index) {
                return _buildVoiceItem(
                  context,
                  ref,
                  state.voices[index],
                  state,
                );
              },
            ),
          ),
          if (state.currentVoice != null) _buildMiniPlayer(context, ref, state),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildVoiceFab(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B9D), Color(0xFFFF8E53)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showVoiceRecordSheet(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        child: const Icon(Icons.mic_rounded, size: 28, color: Colors.white),
      ),
    );
  }

  void _showVoiceRecordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VoiceRecordBottomSheet(),
    );
  }

  Widget _buildVoiceItem(
    BuildContext context,
    WidgetRef ref,
    Voice voice,
    RadioState state,
  ) {
    final isCurrentVoice = state.currentVoice?.audioUrl == voice.audioUrl;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentVoice
            ? Colors.white.withOpacity(0.25)
            : Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentVoice
              ? Colors.white.withOpacity(0.5)
              : Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              ref.read(radioNotifierProvider.notifier).playVoice(voice),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getMoodColor(voice.mood).withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getMoodColor(voice.mood),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isCurrentVoice && state.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: _getMoodColor(voice.mood),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voice.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getMoodColor(voice.mood).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              voice.mood,
                              style: TextStyle(
                                color: _getMoodColor(voice.mood),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${voice.duration}s',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            dateFormat.format(voice.takenAt),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11,
                            ),
                          ),
                        ],
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

  Widget _buildMiniPlayer(
    BuildContext context,
    WidgetRef ref,
    RadioState state,
  ) {
    final voice = state.currentVoice!;
    final progress = state.totalDuration.inMilliseconds > 0
        ? state.currentPosition.inMilliseconds /
              state.totalDuration.inMilliseconds
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getMoodColor(voice.mood),
              ),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getMoodColor(voice.mood).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.graphic_eq_rounded,
                  color: _getMoodColor(voice.mood),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voice.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDuration(state.currentPosition)} / ${_formatDuration(state.totalDuration)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  if (state.isPlaying) {
                    ref.read(radioNotifierProvider.notifier).pauseVoice();
                  } else {
                    ref.read(radioNotifierProvider.notifier).resumeVoice();
                  }
                },
                icon: Icon(
                  state.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.read(radioNotifierProvider.notifier).stopVoice();
                },
                icon: Icon(
                  Icons.stop_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'love':
        return const Color(0xFFFF6B9D);
      case 'happy':
        return const Color(0xFFFFD93D);
      case 'sad':
        return const Color(0xFF6BCB77);
      case 'angry':
        return const Color(0xFFFF6B6B);
      case 'neutral':
        return const Color(0xFF4ECDC4);
      default:
        return AppColors.primaryPink;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
