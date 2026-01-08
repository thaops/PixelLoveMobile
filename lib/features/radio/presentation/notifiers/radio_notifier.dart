import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/radio/domain/entities/voice.dart';
import 'package:pixel_love/features/radio/domain/usecases/get_voices_usecase.dart';
import 'package:pixel_love/features/radio/providers/radio_providers.dart';

class RadioState {
  final List<Voice> voices;
  final int total;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage;
  final Voice? currentVoice;
  final bool isPlaying;
  final Duration currentPosition;
  final Duration totalDuration;

  const RadioState({
    this.voices = const [],
    this.total = 0,
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 1,
    this.currentVoice,
    this.isPlaying = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
  });

  RadioState copyWith({
    List<Voice>? voices,
    int? total,
    bool? isLoading,
    String? errorMessage,
    int? currentPage,
    Voice? currentVoice,
    bool? isPlaying,
    Duration? currentPosition,
    Duration? totalDuration,
    bool clearError = false,
    bool clearCurrentVoice = false,
  }) {
    return RadioState(
      voices: voices ?? this.voices,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      currentVoice: clearCurrentVoice
          ? null
          : (currentVoice ?? this.currentVoice),
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }
}

class RadioNotifier extends Notifier<RadioState> {
  late final GetVoicesUseCase _getVoicesUseCase;
  late final AudioPlayer _audioPlayer;

  @override
  RadioState build() {
    _getVoicesUseCase = ref.watch(getVoicesUseCaseProvider);
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPositionChanged.listen((position) {
      state = state.copyWith(currentPosition: position);
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      state = state.copyWith(totalDuration: duration);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      state = state.copyWith(isPlaying: false, currentPosition: Duration.zero);
    });

    ref.onDispose(() {
      _audioPlayer.dispose();
    });

    Future.microtask(() {
      _loadVoices();
    });
    return const RadioState(isLoading: true);
  }

  Future<void> _loadVoices() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getVoicesUseCase(page: state.currentPage, limit: 20);

    result.when(
      success: (voiceList) {
        state = state.copyWith(
          voices: voiceList.items,
          total: voiceList.total,
          isLoading: false,
        );
      },
      error: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(currentPage: 1);
    await _loadVoices();
  }

  Future<void> playVoice(Voice voice) async {
    if (state.currentVoice?.audioUrl == voice.audioUrl && state.isPlaying) {
      await _audioPlayer.pause();
      state = state.copyWith(isPlaying: false);
      return;
    }

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(voice.audioUrl));
      state = state.copyWith(
        currentVoice: voice,
        isPlaying: true,
        currentPosition: Duration.zero,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Không thể phát audio');
    }
  }

  Future<void> pauseVoice() async {
    await _audioPlayer.pause();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> resumeVoice() async {
    await _audioPlayer.resume();
    state = state.copyWith(isPlaying: true);
  }

  Future<void> stopVoice() async {
    await _audioPlayer.stop();
    state = state.copyWith(
      isPlaying: false,
      currentPosition: Duration.zero,
      clearCurrentVoice: true,
    );
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }
}
