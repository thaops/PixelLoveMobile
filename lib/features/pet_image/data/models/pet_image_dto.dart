import 'package:pixel_love/features/pet_image/domain/entities/pet_image.dart';

class PetReactionGroupDto {
  final String emoji;
  final int count;

  PetReactionGroupDto({required this.emoji, required this.count});

  factory PetReactionGroupDto.fromJson(Map<String, dynamic> json) {
    return PetReactionGroupDto(
      emoji: json['emoji'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'emoji': emoji, 'count': count};
  }

  PetReactionGroup toEntity() {
    return PetReactionGroup(emoji: emoji, count: count);
  }
}

class PetReactionDetailDto {
  final String userId;
  final String displayName;
  final String avatarUrl;
  final String emoji;
  final int count;
  final String updatedAt; // ISO string

  PetReactionDetailDto({
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.emoji,
    required this.count,
    required this.updatedAt,
  });

  factory PetReactionDetailDto.fromJson(Map<String, dynamic> json) {
    return PetReactionDetailDto(
      userId: json['userId'] ?? '',
      displayName: json['displayName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      emoji: json['emoji'] ?? '',
      count: json['count'] ?? 0,
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'emoji': emoji,
      'count': count,
      'updatedAt': updatedAt,
    };
  }

  PetReactionDetail toEntity() {
    return PetReactionDetail(
      userId: userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
      emoji: emoji,
      count: count,
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
    );
  }
}

/// DTO cho Pet Image từ API
class PetImageDto {
  final String id;
  final String imageUrl;
  final String userId;
  final String actionAt; // ISO string
  final String? takenAt; // ISO string, optional
  final int baseExp;
  final int bonusExp;
  final String? mood;
  final String? text;
  final String createdAt; // ISO string

  final String? displayName;
  final String? avatarUrl;

  final int reactionTotalCount;
  final List<PetReactionGroupDto> reactionGroups;
  final List<PetReactionDetailDto> latestDetails;

  PetImageDto({
    required this.id,
    required this.imageUrl,
    required this.userId,
    required this.actionAt,
    this.takenAt,
    required this.baseExp,
    required this.bonusExp,
    this.mood,
    this.text,
    required this.createdAt,
    this.displayName,
    this.avatarUrl,
    this.reactionTotalCount = 0,
    this.reactionGroups = const [],
    this.latestDetails = const [],
  });

  factory PetImageDto.fromJson(Map<String, dynamic> json) {
    int totalCount = 0;
    List<PetReactionGroupDto> groups = [];
    List<PetReactionDetailDto> details = [];

    if (json['reactions'] != null) {
      final reactionsMap = json['reactions'] as Map<String, dynamic>;
      totalCount = reactionsMap['total_count'] ?? 0;
      if (reactionsMap['grouped'] != null) {
        final groupedList = reactionsMap['grouped'] as List<dynamic>;
        groups = groupedList
            .map((g) => PetReactionGroupDto.fromJson(g as Map<String, dynamic>))
            .toList();
      }
      if (reactionsMap['latest_details'] != null) {
        final detailsList = reactionsMap['latest_details'] as List<dynamic>;
        details = detailsList
            .map(
              (d) => PetReactionDetailDto.fromJson(d as Map<String, dynamic>),
            )
            .toList();
      }
    }

    return PetImageDto(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      userId: json['userId'] ?? '',
      actionAt: json['actionAt'] ?? json['createdAt'] ?? '',
      takenAt: json['takenAt'],
      baseExp: json['baseExp'] ?? 20,
      bonusExp: json['bonusExp'] ?? 0,
      mood: json['mood'],
      text: json['text'],
      createdAt: json['createdAt'] ?? '',
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      reactionTotalCount: totalCount,
      reactionGroups: groups,
      latestDetails: details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'userId': userId,
      'actionAt': actionAt,
      'takenAt': takenAt,
      'baseExp': baseExp,
      'bonusExp': bonusExp,
      'mood': mood,
      'text': text,
      'createdAt': createdAt,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'reactions': {
        'total_count': reactionTotalCount,
        'grouped': reactionGroups.map((g) => g.toJson()).toList(),
        'latest_details': latestDetails.map((d) => d.toJson()).toList(),
      },
    };
  }

  PetImage toEntity() {
    return PetImage(
      id: id,
      imageUrl: imageUrl,
      userId: userId,
      actionAt: DateTime.tryParse(actionAt) ?? DateTime.now(),
      takenAt: takenAt != null ? DateTime.tryParse(takenAt!) : null,
      baseExp: baseExp,
      bonusExp: bonusExp,
      mood: mood,
      text: text,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      displayName: displayName,
      avatarUrl: avatarUrl,
      reactionTotalCount: reactionTotalCount,
      reactionGroups: reactionGroups.map((g) => g.toEntity()).toList(),
      latestDetails: latestDetails.map((d) => d.toEntity()).toList(),
    );
  }
}
