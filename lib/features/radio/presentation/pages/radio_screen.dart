import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/widgets/love_background.dart';
import 'package:pixel_love/features/radio/presentation/notifiers/radio_notifier.dart';
import 'package:pixel_love/features/radio/presentation/widgets/radio_empty_view.dart';
import 'package:pixel_love/features/radio/presentation/widgets/radio_error_view.dart';
import 'package:pixel_love/features/radio/presentation/widgets/radio_mini_player.dart';
import 'package:pixel_love/features/radio/presentation/widgets/voice_fab.dart';
import 'package:pixel_love/features/radio/presentation/widgets/voice_list_item.dart';
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.2), Colors.transparent],
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryPink,
                size: 18,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.home);
                }
              },
            ),
          ),
        ),
        title: Text(
          'Voice Messages',
          style: TextStyle(
            color: AppColors.primaryPink,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: VoiceFab(
        onPressed: () => _showVoiceRecordSheet(context),
      ),
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
      return RadioErrorView(
        errorMessage: state.errorMessage!,
        onRetry: () => ref.read(radioNotifierProvider.notifier).refresh(),
      );
    }

    if (state.voices.isEmpty) {
      return const RadioEmptyView();
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.voices.length,
              itemBuilder: (context, index) {
                final voice = state.voices[index];
                final isCurrentVoice =
                    state.currentVoice?.audioUrl == voice.audioUrl;
                return VoiceListItem(
                  voice: voice,
                  isCurrent: isCurrentVoice,
                  isPlaying: state.isPlaying,
                  onTap: () =>
                      ref.read(radioNotifierProvider.notifier).playVoice(voice),
                  onPin: () => ref
                      .read(radioNotifierProvider.notifier)
                      .pinVoice(voice.id),
                  onDelete: () => ref
                      .read(radioNotifierProvider.notifier)
                      .deleteVoice(voice.id),
                );
              },
            ),
          ),
          if (state.currentVoice != null)
            RadioMiniPlayer(
              voice: state.currentVoice!,
              isPlaying: state.isPlaying,
              progress: state.totalDuration.inMilliseconds > 0
                  ? state.currentPosition.inMilliseconds /
                        state.totalDuration.inMilliseconds
                  : 0.0,
              currentPosition: state.currentPosition,
              totalDuration: state.totalDuration,
              onPlayPause: () {
                if (state.isPlaying) {
                  ref.read(radioNotifierProvider.notifier).pauseVoice();
                } else {
                  ref.read(radioNotifierProvider.notifier).resumeVoice();
                }
              },
              onStop: () =>
                  ref.read(radioNotifierProvider.notifier).stopVoice(),
            ),
          const SizedBox(height: 80),
        ],
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
}
