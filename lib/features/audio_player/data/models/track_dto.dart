import '../../domain/entities/track.dart';

class TrackDto {
  final String id;
  final String title;
  final String thumbnail;
  final String audioUrl;
  final num duration;
  final String status;
  final int progress;

  TrackDto({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.audioUrl,
    required this.duration,
    required this.status,
    required this.progress,
  });

  factory TrackDto.fromJson(Map<String, dynamic> json) {
    return TrackDto(
      id: json['_id'] ?? json['trackId'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      duration: json['duration'] ?? 0,
      status: json['status'] ?? 'ready',
      progress: json['progress'] ?? (json['status'] == 'ready' ? 100 : 0),
    );
  }

  Track toEntity() {
    return Track(
      id: id,
      title: title,
      thumbnail: thumbnail,
      audioUrl: audioUrl,
      duration: duration,
      status: status,
      progress: progress,
    );
  }
}
