import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/radio/data/models/voice_dto.dart';
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

    // Load from cache
    final storageService = ref.read(storageServiceProvider);
    final cachedData = storageService.getVoicesData();
    VoiceList? cachedList;

    if (cachedData != null) {
      try {
        final dto = VoiceListDto.fromJson(cachedData);
        cachedList = dto.toEntity();
      } catch (e) {
        // Ignore cache error
      }
    }

    if (cachedList != null) {
      // Sort cached data
      final sortedVoices = List<Voice>.from(cachedList.items);
      sortedVoices.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

      // Load silently in background
      Future.microtask(() {
        _loadVoices(silent: true);
      });

      return RadioState(
        voices: sortedVoices,
        total: cachedList.total,
        isLoading: false,
      );
    } else {
      // No cache, normal load
      Future.microtask(() {
        _loadVoices();
      });
      return const RadioState(isLoading: true);
    }
  }

  Future<void> _loadVoices({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(clearError: true);
    }

    final result = await _getVoicesUseCase(page: state.currentPage, limit: 20);

    result.when(
      success: (voiceList) {
        final sortedVoices = List<Voice>.from(voiceList.items);
        sortedVoices.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });

        state = state.copyWith(
          voices: sortedVoices,
          total: voiceList.total,
          isLoading: false,
        );

        // Save to cache
        try {
          final storageService = ref.read(storageServiceProvider);
          final voiceDtos = voiceList.items
              .map(
                (v) => VoiceDto(
                  id: v.id,
                  audioUrl: v.audioUrl,
                  duration: v.duration,
                  oderId: v.oderId,
                  actionAt: v.actionAt,
                  takenAt: v.takenAt,
                  baseExp: v.baseExp,
                  bonusExp: v.bonusExp,
                  text: v.text,
                  mood: v.mood,
                  createdAt: v.createdAt,
                  isPinned: v.isPinned,
                ),
              )
              .toList();

          final listDto = VoiceListDto(
            items: voiceDtos,
            total: voiceList.total,
          );
          storageService.saveVoicesData(listDto.toJson());
        } catch (e) {
          // Ignore save cache error
        }
      },
      error: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(currentPage: 1);
    await _loadVoices(silent: true);
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

  Future<bool> deleteVoice(String voiceId) async {
    final dataSource = ref.read(radioRemoteDataSourceProvider);
    final result = await dataSource.deleteVoice(voiceId);

    return result.when(
      success: (response) {
        if (response.success) {
          final updatedVoices = state.voices
              .where((v) => v.id != voiceId)
              .toList();
          if (state.currentVoice?.id == voiceId) {
            stopVoice();
          }
          state = state.copyWith(voices: updatedVoices, total: state.total - 1);
          _loadVoices(silent: true);
          return true;
        }
        return false;
      },
      error: (error) {
        state = state.copyWith(errorMessage: error.message);
        return false;
      },
    );
  }

  Future<bool> pinVoice(String voiceId) async {
    final dataSource = ref.read(radioRemoteDataSourceProvider);
    final result = await dataSource.pinVoice(voiceId);

    return result.when(
      success: (response) {
        if (response.success) {
          final updatedVoices = state.voices.map((v) {
            if (v.id == voiceId) {
              return v.copyWith(isPinned: response.isPinned);
            }
            return v;
          }).toList();
          updatedVoices.sort((a, b) {
            if (a.isPinned && !b.isPinned) return -1;
            if (!a.isPinned && b.isPinned) return 1;
            return b.createdAt.compareTo(a.createdAt);
          });
          state = state.copyWith(voices: updatedVoices);
          _loadVoices(silent: true);
          return true;
        }
        return false;
      },
      error: (error) {
        state = state.copyWith(errorMessage: error.message);
        return false;
      },
    );
  }
}
