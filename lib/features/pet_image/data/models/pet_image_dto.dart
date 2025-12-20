import 'package:pixel_love/features/pet_image/domain/entities/pet_image.dart';

/// DTO cho Pet Image từ API
class PetImageDto {
  final String imageUrl;
  final String userId;
  final String actionAt; // ISO string
  final String? takenAt; // ISO string, optional
  final int baseExp;
  final int bonusExp;
  final String? mood;
  final String? text;
  final String createdAt; // ISO string

  PetImageDto({
    required this.imageUrl,
    required this.userId,
    required this.actionAt,
    this.takenAt,
    required this.baseExp,
    required this.bonusExp,
    this.mood,
    this.text,
    required this.createdAt,
  });

  factory PetImageDto.fromJson(Map<String, dynamic> json) {
    return PetImageDto(
      imageUrl: json['imageUrl'] ?? '',
      userId: json['userId'] ?? '',
      actionAt: json['actionAt'] ?? json['createdAt'] ?? '',
      takenAt: json['takenAt'],
      baseExp: json['baseExp'] ?? 20,
      bonusExp: json['bonusExp'] ?? 0,
      mood: json['mood'],
      text: json['text'],
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'userId': userId,
      'actionAt': actionAt,
      'takenAt': takenAt,
      'baseExp': baseExp,
      'bonusExp': bonusExp,
      'mood': mood,
      'text': text,
      'createdAt': createdAt,
    };
  }

  PetImage toEntity() {
    return PetImage(
      imageUrl: imageUrl,
      userId: userId,
      actionAt: DateTime.parse(actionAt),
      takenAt: takenAt != null ? DateTime.tryParse(takenAt!) : null,
      baseExp: baseExp,
      bonusExp: bonusExp,
      mood: mood,
      text: text,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
