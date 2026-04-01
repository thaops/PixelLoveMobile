import 'package:equatable/equatable.dart';

class Leaderboard extends Equatable {
  final int myRank;
  final int myStreak;
  final int myLpScore;
  final List<LeaderboardUser> items;

  Leaderboard({
    required this.myRank,
    required this.myStreak,
    required this.myLpScore,
    required this.items,
  });

  @override
  List<Object?> get props => [myRank, myStreak, myLpScore, items];
}

class LeaderboardUser extends Equatable {
  final String coupleId;
  final Pet pet;
  final List<Members> members;
  final String backgroundUrl;
  final int streak;
  final int loveDays;
  final int rank;
  final int lpScore;
  final int heartsCount;

  LeaderboardUser({
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

  @override
  List<Object?> get props => [
    coupleId,
    pet,
    members,
    backgroundUrl,
    streak,
    loveDays,
    rank,
    lpScore,
    heartsCount,
  ];
}

class Members extends Equatable {
  final String userId;
  final String name;
  final String avatarUrl;
  Members({required this.userId, required this.name, required this.avatarUrl});

  @override
  List<Object?> get props => [userId, name, avatarUrl];
}

class Pet extends Equatable {
  final String level;
  Pet({required this.level});

  @override
  List<Object?> get props => [level];
}
