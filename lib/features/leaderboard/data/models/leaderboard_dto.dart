import 'package:pixel_love/features/leaderboard/domain/entities/leaderboard.dart';

class LeaderboardDto {
  final int myRank;
  final int myStreak;
  final int myLpScore;
  final List<LeaderboardUserDto> items;
  LeaderboardDto({
    required this.myRank,
    required this.myStreak,
    required this.myLpScore,
    required this.items,
  });
  factory LeaderboardDto.fromJson(Map<String, dynamic> json) {
    return LeaderboardDto(
      myRank: json['myRank'] ?? 0,
      myStreak: json['myStreak'] ?? 0,
      myLpScore: json['myLpScore'] ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => LeaderboardUserDto.fromJson(item))
              .toList() ??
          [],
    );
  }
  Leaderboard toEntity() {
    return Leaderboard(
      myRank: myRank,
      myStreak: myStreak,
      myLpScore: myLpScore,
      items: items.map((item) => item.toEntity()).toList(),
    );
  }
}

class LeaderboardUserDto {
  final String coupleId;
  final PetDto pet;
  final List<MembersDto> members;
  final String backgroundUrl;
  final int streak;
  final int loveDays;
  final int rank;
  final int lpScore;
  final int heartsCount;

  LeaderboardUserDto({
    required this.coupleId,
    required this.pet,
    required this.members,
    required this.backgroundUrl,
    required this.streak,
    required this.loveDays,
    required this.rank,
    required this.lpScore,
    required this.heartsCount,
  });
  factory LeaderboardUserDto.fromJson(Map<String, dynamic> json) {
    return LeaderboardUserDto(
      coupleId: json['coupleId'] ?? '',
      pet: PetDto.fromJson(json['pet']),
      members:
          (json['members'] as List<dynamic>?)
              ?.map((item) => MembersDto.fromJson(item))
              .toList() ??
          [],
      backgroundUrl: json['backgroundUrl'] ?? '',
      streak: json['streak'] ?? 0,
      loveDays: json['loveDays'] ?? 0,
      rank: json['rank'] ?? 0,
      lpScore: json['lpScore'] ?? 0,
      heartsCount: json['heartsCount'] ?? 0,
    );
  }
  LeaderboardUser toEntity() {
    return LeaderboardUser(
      coupleId: coupleId,
      pet: pet.toEntity(),
      members: members.map((item) => item.toEntity()).toList(),
      backgroundUrl: backgroundUrl,
      streak: streak,
      loveDays: loveDays,
      rank: rank,
      lpScore: lpScore,
      heartsCount: heartsCount,
    );
  }
}

class MembersDto {
  final String userId;
  final String name;
  final String avatarUrl;
  MembersDto({
    required this.userId,
    required this.name,
    required this.avatarUrl,
  });
  factory MembersDto.fromJson(Map<String, dynamic> json) {
    return MembersDto(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }

  Members toEntity() {
    return Members(userId: userId, name: name, avatarUrl: avatarUrl);
  }
}

class PetDto {
  final String level;
  PetDto({required this.level});
  factory PetDto.fromJson(Map<String, dynamic> json) {
    return PetDto(level: json['level'].toString());
  }

  Pet toEntity() {
    return Pet(level: level);
  }
}

class CoupleDetailDto {
  final String coupleId;
  final String bio;
  final List<String> gallery;
  final LeaderboardUserStatsDto stats;
  final List<MembersDto> members;

  CoupleDetailDto({
    required this.coupleId,
    required this.bio,
    required this.gallery,
    required this.stats,
    required this.members,
  });

  factory CoupleDetailDto.fromJson(Map<String, dynamic> json) {
    return CoupleDetailDto(
      coupleId: json['coupleId'] ?? '',
      bio: json['bio'] ?? '',
      gallery: List<String>.from(json['gallery'] ?? []),
      stats: LeaderboardUserStatsDto.fromJson(json['stats'] ?? {}),
      members:
          (json['members'] as List<dynamic>?)
              ?.map((item) => MembersDto.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class LeaderboardUserStatsDto {
  final int streak;
  final int loveDays;
  final int petLevel;
  final int totalHearts;

  LeaderboardUserStatsDto({
    required this.streak,
    required this.loveDays,
    required this.petLevel,
    required this.totalHearts,
  });

  factory LeaderboardUserStatsDto.fromJson(Map<String, dynamic> json) {
    return LeaderboardUserStatsDto(
      streak: json['streak'] ?? 0,
      loveDays: json['loveDays'] ?? 0,
      petLevel: json['petLevel'] ?? 0,
      totalHearts: json['totalHearts'] ?? 0,
    );
  }
}

class HeartResponseDto {
  final bool success;
  final int newHeartsCount;
  final int newLpScore;

  HeartResponseDto({
    required this.success,
    required this.newHeartsCount,
    required this.newLpScore,
  });

  factory HeartResponseDto.fromJson(Map<String, dynamic> json) {
    return HeartResponseDto(
      success: json['success'] ?? false,
      newHeartsCount: json['newHeartsCount'] ?? 0,
      newLpScore: json['newLpScore'] ?? 0,
    );
  }
}
