import 'package:equatable/equatable.dart';

class VideoItems extends Equatable {
  final String id;
  final String videoId;
  final String title;
  final String thumbnail;

  const VideoItems({
    required this.id,
    required this.videoId,
    required this.title,
    required this.thumbnail,
  });

  VideoItems copyWith({
    String? id,
    String? videoId,
    String? title,
    String? thumbnail,
  }) {
    return VideoItems(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  @override
  List<Object?> get props => [id, videoId, title, thumbnail];
}
