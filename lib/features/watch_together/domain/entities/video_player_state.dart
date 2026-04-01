import 'package:equatable/equatable.dart';
import 'package:pixel_love/features/watch_together/domain/entities/video_items.dart';

class VideoPlayerState extends Equatable {
  final String mode;
  final String? videoId;
  final String? currentId;
  final List<VideoItems> videoItems;
  final int currentIndex;
  final double currentTime;
  final bool isPlaying;
  final int? serverTime;

  const VideoPlayerState({
    required this.mode,
    required this.videoId,
    required this.currentId,
    required this.videoItems,
    required this.currentIndex,
    required this.currentTime,
    required this.isPlaying,
    required this.serverTime,
  });

  VideoPlayerState copyWith({
    String? mode,
    String? videoId,
    String? currentId,
    List<VideoItems>? videoItems,
    int? currentIndex,
    double? currentTime,
    bool? isPlaying,
    int? severTime,
  }) {
    return VideoPlayerState(
      mode: mode ?? this.mode,
      videoId: videoId ?? this.videoId,
      currentId: currentId ?? this.currentId,
      videoItems: videoItems ?? this.videoItems,
      currentIndex: currentIndex ?? this.currentIndex,
      currentTime: currentTime ?? this.currentTime,
      isPlaying: isPlaying ?? this.isPlaying,
      serverTime: serverTime ?? this.serverTime,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    videoId,
    currentId,
    videoItems,
    currentIndex,
    currentTime,
    isPlaying,
    serverTime,
  ];
}
