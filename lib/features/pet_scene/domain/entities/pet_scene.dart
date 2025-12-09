import 'package:equatable/equatable.dart';

class PetScene extends Equatable {
  final Background background;
  final List<SceneObject> objects;
  final PetStatus petStatus;

  const PetScene({
    required this.background,
    required this.objects,
    required this.petStatus,
  });

  @override
  List<Object?> get props => [background, objects, petStatus];
}

class Background extends Equatable {
  final String imageUrl;
  final double width;
  final double height;

  const Background({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  List<Object?> get props => [imageUrl, width, height];
}

class SceneObject extends Equatable {
  final String id;
  final String type;
  final String imageUrl;
  final double x;
  final double y;
  final double width;
  final double height;
  final int zIndex;

  const SceneObject({
    required this.id,
    required this.type,
    required this.imageUrl,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.zIndex,
  });

  @override
  List<Object?> get props => [id, type, imageUrl, x, y, width, height, zIndex];
}

class PetStatus extends Equatable {
  final int level;
  final int exp;
  final int expToNextLevel;
  final int todayFeedCount;
  final DateTime? lastFeedTime;

  const PetStatus({
    required this.level,
    required this.exp,
    required this.expToNextLevel,
    required this.todayFeedCount,
    this.lastFeedTime,
  });

  @override
  List<Object?> get props => [
    level,
    exp,
    expToNextLevel,
    todayFeedCount,
    lastFeedTime,
  ];
}
