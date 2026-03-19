import 'track.dart';

class AudioPlayerState {
  final Track? currentTrack;
  final bool isPlaying;
  final num currentTime;
  final List<Track> queue;
  final String? partnerAvatar;
  final String? partnerName;
  final bool isPartnerOnline;
  final bool isLoading;
  final String? timerEndsAt;
  final int currentIndex;
  final int totalItems;

  AudioPlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.currentTime = 0,
    this.queue = const [],
    this.partnerAvatar,
    this.partnerName,
    this.isPartnerOnline = false,
    this.isLoading = false,
    this.timerEndsAt,
    this.currentIndex = 0,
    this.totalItems = 0,
  });

  AudioPlayerState copyWith({
    Track? currentTrack,
    bool? isPlaying,
    num? currentTime,
    List<Track>? queue,
    String? partnerAvatar,
    String? partnerName,
    bool? isPartnerOnline,
    bool? isLoading,
    String? timerEndsAt,
    int? currentIndex,
    int? totalItems,
  }) {
    return AudioPlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      currentTime: currentTime ?? this.currentTime,
      queue: queue ?? this.queue,
      partnerAvatar: partnerAvatar ?? this.partnerAvatar,
      partnerName: partnerName ?? this.partnerName,
      isPartnerOnline: isPartnerOnline ?? this.isPartnerOnline,
      isLoading: isLoading ?? this.isLoading,
      timerEndsAt: timerEndsAt ?? this.timerEndsAt,
      currentIndex: currentIndex ?? this.currentIndex,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}
