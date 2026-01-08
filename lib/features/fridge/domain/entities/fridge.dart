import 'package:equatable/equatable.dart';

class Fridge extends Equatable {
  final FridgeBackground background;
  final List<FridgeNote> notes;

  const Fridge({required this.background, required this.notes});

  @override
  List<Object?> get props => [background, notes];
}

class FridgeBackground extends Equatable {
  final String imageUrl;
  final String aspectRatio;

  const FridgeBackground({required this.imageUrl, required this.aspectRatio});

  @override
  List<Object?> get props => [imageUrl, aspectRatio];
}

class FridgeNote extends Equatable {
  final String id;
  final String content;
  final String frameImageUrl;
  final NotePosition position;
  final double rotation;
  final int zIndex;
  final DateTime createdAt;

  const FridgeNote({
    required this.id,
    required this.content,
    required this.frameImageUrl,
    required this.position,
    required this.rotation,
    required this.zIndex,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    content,
    frameImageUrl,
    position,
    rotation,
    zIndex,
    createdAt,
  ];
}

class NotePosition extends Equatable {
  final double x;
  final double y;

  const NotePosition({required this.x, required this.y});

  @override
  List<Object?> get props => [x, y];
}
