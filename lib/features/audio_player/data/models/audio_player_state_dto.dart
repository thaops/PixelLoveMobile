import '../../domain/entities/audio_player_state.dart';
import '../../domain/entities/track.dart';
import 'track_dto.dart';

class AudioPlayerStateDto {
  final TrackDto? currentTrack;
  final bool isPlaying;
  final num currentTime;
  final List<TrackDto> queue;

  AudioPlayerStateDto({
    this.currentTrack,
    required this.isPlaying,
    required this.currentTime,
    required this.queue,
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
    );
  }

  AudioPlayerState toEntity() {
    return AudioPlayerState(
      currentTrack: currentTrack?.toEntity(),
      isPlaying: isPlaying,
      currentTime: currentTime,
      queue: queue.map((e) => e.toEntity()).toList(),
    );
  }
}
