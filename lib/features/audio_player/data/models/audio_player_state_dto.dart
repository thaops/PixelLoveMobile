import '../../domain/entities/audio_player_state.dart';
import 'track_dto.dart';

class AudioPlayerStateDto {
  final TrackDto? currentTrack;
  final bool isPlaying;
  final num currentTime;
  final List<TrackDto> queue;
  final String? timerEndsAt;
  final int currentIndex;
  final int totalItems;

  AudioPlayerStateDto({
    this.currentTrack,
    required this.isPlaying,
    required this.currentTime,
    required this.queue,
    this.timerEndsAt,
    required this.currentIndex,
    required this.totalItems,
  });

  factory AudioPlayerStateDto.fromJson(Map<String, dynamic> json) {
    List<TrackDto> queueList = [];
    if (json['queue'] != null && json['queue'] is List) {
      queueList = (json['queue'] as List)
          .map((item) => TrackDto.fromJson(item))
          .toList();
    }

    return AudioPlayerStateDto(
      currentTrack: json['currentTrack'] != null
          ? TrackDto.fromJson(json['currentTrack'])
          : null,
      isPlaying: json['isPlaying'] ?? false,
      currentTime: json['currentTime'] ?? 0,
      queue: queueList,
      timerEndsAt: json['timerEndsAt'],
      currentIndex: json['currentIndex'] ?? 0,
      totalItems: json['totalItems'] ?? 0,
    );
  }

  AudioPlayerState toEntity() {
    return AudioPlayerState(
      currentTrack: currentTrack?.toEntity(),
      isPlaying: isPlaying,
      currentTime: currentTime,
      queue: queue.map((e) => e.toEntity()).toList(),
      timerEndsAt: timerEndsAt,
      currentIndex: currentIndex,
      totalItems: totalItems,
    );
  }
}
