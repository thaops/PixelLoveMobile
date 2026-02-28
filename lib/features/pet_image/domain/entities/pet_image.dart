import 'package:equatable/equatable.dart';

class PetReactionGroup extends Equatable {
  final String emoji;
  final int count;

  const PetReactionGroup({required this.emoji, required this.count});

  @override
  List<Object?> get props => [emoji, count];
}

class PetReactionDetail extends Equatable {
  final String userId;
  final String displayName;
  final String avatarUrl;
  final String emoji;
  final int count;
  final DateTime updatedAt;

  const PetReactionDetail({
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.emoji,
    required this.count,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    userId,
    displayName,
    avatarUrl,
    emoji,
    count,
    updatedAt,
  ];
}

/// Entity đại diện cho một ảnh đã gửi cho pet
class PetImage extends Equatable {
  final String id;
  final String imageUrl;
  final String userId;
  final DateTime actionAt; // Thời điểm gửi ảnh
  final DateTime? takenAt; // Thời điểm chụp ảnh (optional)
  final int baseExp; // EXP cơ bản
  final int bonusExp; // EXP bonus (0 hoặc 20)
  final String? mood; // Tâm trạng pet (optional)
  final String? text; // Caption (optional)
  final DateTime createdAt; // Timestamp tạo record

  final String? displayName; // Tên người đăng
  final String? avatarUrl; // Avatar người đăng

  final int reactionTotalCount;
  final List<PetReactionGroup> reactionGroups;
  final List<PetReactionDetail> latestDetails;

  const PetImage({
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

  /// Tổng EXP nhận được
  int get totalExp => baseExp + bonusExp;

  /// Có bonus EXP không
  bool get hasBonus => bonusExp > 0;

  @override
  List<Object?> get props => [
    id,
    imageUrl,
    userId,
    actionAt,
    takenAt,
    baseExp,
    bonusExp,
    mood,
    text,
    createdAt,
    displayName,
    avatarUrl,
    reactionTotalCount,
    reactionGroups,
    latestDetails,
  ];

  PetImage copyWith({
    String? id,
    String? imageUrl,
    String? userId,
    DateTime? actionAt,
    DateTime? takenAt,
    int? baseExp,
    int? bonusExp,
    String? mood,
    String? text,
    DateTime? createdAt,
    String? displayName,
    String? avatarUrl,
    int? reactionTotalCount,
    List<PetReactionGroup>? reactionGroups,
    List<PetReactionDetail>? latestDetails,
  }) {
    return PetImage(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      actionAt: actionAt ?? this.actionAt,
      takenAt: takenAt ?? this.takenAt,
      baseExp: baseExp ?? this.baseExp,
      bonusExp: bonusExp ?? this.bonusExp,
      mood: mood ?? this.mood,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      reactionTotalCount: reactionTotalCount ?? this.reactionTotalCount,
      reactionGroups: reactionGroups ?? this.reactionGroups,
      latestDetails: latestDetails ?? this.latestDetails,
    );
  }
}
