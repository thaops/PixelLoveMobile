import 'package:equatable/equatable.dart';

class Streak extends Equatable {
  final int days;
  final String level;
  final String missingSide;
  final int hoursToBreak;

  const Streak({
    required this.days,
    required this.level,
    required this.missingSide,
    required this.hoursToBreak,
  });

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      days: json['days'] ?? 0,
      level: json['level'] ?? 'broken',
      missingSide: json['missingSide'] ?? '',
      hoursToBreak: json['hoursToBreak'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [days, level, missingSide, hoursToBreak];
}
