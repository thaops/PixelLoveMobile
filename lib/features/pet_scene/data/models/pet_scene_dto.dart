import 'package:pixel_love/features/pet_scene/domain/entities/pet_scene.dart';

class PetSceneDto {
  final BackgroundDto background;
  final List<SceneObjectDto> objects;
  final PetStatusDto petStatus;

  PetSceneDto({
    required this.background,
    required this.objects,
    required this.petStatus,
  });

  factory PetSceneDto.fromJson(Map<String, dynamic> json) {
    return PetSceneDto(
      background: BackgroundDto.fromJson(json['background'] ?? {}),
      objects:
          (json['objects'] as List<dynamic>?)
              ?.map((item) => SceneObjectDto.fromJson(item))
              .toList() ??
          [],
      petStatus: PetStatusDto.fromJson(json['petStatus'] ?? {}),
    );
  }

  PetScene toEntity() {
    return PetScene(
      background: background.toEntity(),
      objects: objects.map((obj) => obj.toEntity()).toList(),
      petStatus: petStatus.toEntity(),
    );
  }
}

class BackgroundDto {
  final String imageUrl;
  final double width;
  final double height;

  BackgroundDto({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  factory BackgroundDto.fromJson(Map<String, dynamic> json) {
    return BackgroundDto(
      imageUrl: json['imageUrl'] ?? '',
      width: (json['width'] ?? 1242).toDouble(),
      height: (json['height'] ?? 2688).toDouble(),
    );
  }

  Background toEntity() {
    return Background(imageUrl: imageUrl, width: width, height: height);
  }
}

class SceneObjectDto {
  final String id;
  final String type;
  final String imageUrl;
  final double x;
  final double y;
  final double width;
  final double height;
  final int zIndex;

  SceneObjectDto({
    required this.id,
    required this.type,
    required this.imageUrl,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.zIndex,
  });

  factory SceneObjectDto.fromJson(Map<String, dynamic> json) {
    return SceneObjectDto(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      width: (json['width'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      zIndex: json['zIndex'] ?? 0,
    );
  }

  SceneObject toEntity() {
    return SceneObject(
      id: id,
      type: type,
      imageUrl: imageUrl,
      x: x,
      y: y,
      width: width,
      height: height,
      zIndex: zIndex,
    );
  }
}

class PetStatusDto {
  final int level;
  final int exp;
  final int expToNextLevel;
  final int todayFeedCount;
  final String? lastFeedTime;

  PetStatusDto({
    required this.level,
    required this.exp,
    required this.expToNextLevel,
    required this.todayFeedCount,
    this.lastFeedTime,
  });

  factory PetStatusDto.fromJson(Map<String, dynamic> json) {
    return PetStatusDto(
      level: json['level'] ?? 1,
      exp: json['exp'] ?? 0,
      expToNextLevel: json['expToNextLevel'] ?? 500,
      todayFeedCount: json['todayFeedCount'] ?? 0,
      lastFeedTime: json['lastFeedTime'],
    );
  }

  PetStatus toEntity() {
    return PetStatus(
      level: level,
      exp: exp,
      expToNextLevel: expToNextLevel,
      todayFeedCount: todayFeedCount,
      lastFeedTime: lastFeedTime != null
          ? DateTime.tryParse(lastFeedTime!)
          : null,
    );
  }
}
