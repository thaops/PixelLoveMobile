import 'package:equatable/equatable.dart';

class Pet extends Equatable {
  final String id;
  final String userId;
  final int level;
  final int exp;
  final int maxExp;
  final String status;
  final int hunger;
  final int happiness;
  final DateTime? lastFedAt;

  const Pet({
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

  bool get isHungry => hunger < 30;
  bool get isHappy => happiness > 70;

  @override
  List<Object?> get props => [
        id,
        userId,
        level,
        exp,
        maxExp,
        status,
        hunger,
        happiness,
        lastFedAt,
      ];
}
