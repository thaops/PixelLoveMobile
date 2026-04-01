// lib/features/watch_together/data/models/video_room_state_dto.dart
import 'package:pixel_love/features/watch_together/data/models/video_item_dto.dart';
import 'package:pixel_love/features/watch_together/domain/entities/video_player_state.dart';

class VideoRoomStateDto {
  final String mode;
  final String? videoId;
  final String? currentId;
  final List<VideoItemDto> videoQueue;
  final int currentIndex;
  final double currentTime;
  final bool isPlaying;
  final int? serverTime;

  VideoRoomStateDto({
    required this.mode,
    this.videoId,
    this.currentId,
    required this.videoQueue,
    required this.currentIndex,
    required this.currentTime,
    required this.isPlaying,
    this.serverTime,
  });

  factory VideoRoomStateDto.fromJson(Map<String, dynamic> json) {
    final rawQueue = json['videoQueue'] as List<dynamic>? ?? [];
    return VideoRoomStateDto(
      mode: json['mode'] as String? ?? 'video',
      videoId: json['videoId'] as String?,
      currentId: json['currentId'] as String?,
      videoQueue: rawQueue
          .map((e) => VideoItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentIndex: json['currentIndex'] as int? ?? 0,
      currentTime: (json['currentTime'] as num?)?.toDouble() ?? 0.0,
      isPlaying: json['isPlaying'] as bool? ?? false,
      serverTime: json['serverTime'] as int?,
    );
  }

  VideoPlayerState toEntity() => VideoPlayerState(
        mode: mode,
        videoId: videoId,
        currentId: currentId,
        videoItems: videoQueue.map((e) => e.toEntity()).toList(),
        currentIndex: currentIndex,
        currentTime: currentTime,
        isPlaying: isPlaying,
        serverTime: serverTime,
      );
}
