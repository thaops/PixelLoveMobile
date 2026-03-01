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

  AudioPlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.currentTime = 0,
    this.queue = const [],
    this.partnerAvatar,
    this.partnerName,
    this.isPartnerOnline = true,
    this.isLoading = false,
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
    );
  }
}
