import 'package:pixel_love/features/pet/domain/entities/pet.dart';

class PetDto {
  final String id;
  final String userId;
  final int level;
  final int exp;
  final int maxExp;
  final String status;
  final int hunger;
  final int happiness;
  final String? lastFedAt;

  PetDto({
    required this.id,
    required this.userId,
    required this.level,
    required this.exp,
    required this.maxExp,
    required this.status,
    required this.hunger,
    required this.happiness,
    this.lastFedAt,
  });

  factory PetDto.fromJson(Map<String, dynamic> json) {
    return PetDto(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      level: json['petLevel'] ?? json['level'] ?? 1, // Backend trả về petLevel
      exp: json['exp'] ?? 0,
      maxExp: json['maxExp'] ?? 100,
      status:
          json['petType'] ?? json['status'] ?? 'idle', // Backend trả về petType
      hunger: json['hunger'] ?? 100,
      happiness: json['happiness'] ?? 100,
      lastFedAt: json['lastFedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'level': level,
      'exp': exp,
      'maxExp': maxExp,
      'status': status,
      'hunger': hunger,
      'happiness': happiness,
      'lastFedAt': lastFedAt,
    };
  }

  Pet toEntity() {
    return Pet(
      id: id,
      userId: userId,
      level: level,
      exp: exp,
      maxExp: maxExp,
      status: status,
      hunger: hunger,
      happiness: happiness,
      lastFedAt: lastFedAt != null ? DateTime.tryParse(lastFedAt!) : null,
    );
  }
}
