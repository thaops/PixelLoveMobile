import 'package:pixel_love/features/watch_together/domain/entities/video_items.dart';

class VideoItemDto {
  final String id;
  final String videoId;
  final String title;
  final String thumbnail;

  VideoItemDto({
    required this.id,
    required this.videoId,
    required this.title,
    required this.thumbnail,
  });

  
  factory VideoItemDto.fromJson(Map<String, dynamic> json) => VideoItemDto(
    id: json['id'],
    videoId: json['videoId'],
    title: json['title'],
    thumbnail: json['thumbnail'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'videoId': videoId,
    'title': title,
    'thumbnail': thumbnail,
  };

  VideoItems toEntity() => VideoItems(
    id: id,
    videoId: videoId,
    title: title,
    thumbnail: thumbnail,
  );
}