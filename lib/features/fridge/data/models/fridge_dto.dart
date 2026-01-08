import 'package:pixel_love/features/fridge/domain/entities/fridge.dart';

class FridgeDto {
  final FridgeBackgroundDto background;
  final List<FridgeNoteDto> notes;

  FridgeDto({
    required this.background,
    required this.notes,
  });

  factory FridgeDto.fromJson(Map<String, dynamic> json) {
    return FridgeDto(
      background: FridgeBackgroundDto.fromJson(json['background'] ?? {}),
      notes: (json['notes'] as List<dynamic>?)
              ?.map((item) => FridgeNoteDto.fromJson(item))
              .toList() ??
          [],
    );
  }

  Fridge toEntity() {
    return Fridge(
      background: background.toEntity(),
      notes: notes.map((note) => note.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'background': background.toJson(),
      'notes': notes.map((note) => note.toJson()).toList(),
    };
  }
}

class FridgeBackgroundDto {
  final String imageUrl;
  final String aspectRatio;

  FridgeBackgroundDto({
    required this.imageUrl,
    required this.aspectRatio,
  });

  factory FridgeBackgroundDto.fromJson(Map<String, dynamic> json) {
    return FridgeBackgroundDto(
      imageUrl: json['imageUrl'] ?? '',
      aspectRatio: json['aspectRatio'] ?? '9:16',
    );
  }

  FridgeBackground toEntity() {
    return FridgeBackground(
      imageUrl: imageUrl,
      aspectRatio: aspectRatio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'aspectRatio': aspectRatio,
    };
  }
}

class FridgeNoteDto {
  final String id;
  final String content;
  final String frameImageUrl;
  final NotePositionDto position;
  final double rotation;
  final int zIndex;
  final DateTime createdAt;

  FridgeNoteDto({
    required this.id,
    required this.content,
    required this.frameImageUrl,
    required this.position,
    required this.rotation,
    required this.zIndex,
    required this.createdAt,
  });

  factory FridgeNoteDto.fromJson(Map<String, dynamic> json) {
    return FridgeNoteDto(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      frameImageUrl: json['frameImageUrl'] ?? '',
      position: NotePositionDto.fromJson(json['position'] ?? {}),
      rotation: (json['rotation'] ?? 0).toDouble(),
      zIndex: json['zIndex'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  FridgeNote toEntity() {
    return FridgeNote(
      id: id,
      content: content,
      frameImageUrl: frameImageUrl,
      position: position.toEntity(),
      rotation: rotation,
      zIndex: zIndex,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'frameImageUrl': frameImageUrl,
      'position': position.toJson(),
      'rotation': rotation,
      'zIndex': zIndex,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class NotePositionDto {
  final double x;
  final double y;

  NotePositionDto({
    required this.x,
    required this.y,
  });

  factory NotePositionDto.fromJson(Map<String, dynamic> json) {
    return NotePositionDto(
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
    );
  }

  NotePosition toEntity() {
    return NotePosition(
      x: x,
      y: y,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}

