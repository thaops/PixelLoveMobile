import 'package:equatable/equatable.dart';

class Voice extends Equatable {
  final String audioUrl;
  final int duration;
  final String userId;
  final DateTime actionAt;
  final DateTime takenAt;
  final int baseExp;
  final int bonusExp;
  final String text;
  final String mood;
  final DateTime createdAt;

  const Voice({
    required this.audioUrl,
    required this.duration,
    required this.userId,
    required this.actionAt,
    required this.takenAt,
    required this.baseExp,
    required this.bonusExp,
    required this.text,
    required this.mood,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    audioUrl,
    duration,
    userId,
    actionAt,
    takenAt,
    baseExp,
    bonusExp,
    text,
    mood,
    createdAt,
  ];
}

class VoiceList extends Equatable {
  final List<Voice> items;
  final int total;

  const VoiceList({required this.items, required this.total});

  @override
  List<Object?> get props => [items, total];
}
