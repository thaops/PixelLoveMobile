import 'package:equatable/equatable.dart';

class Voice extends Equatable {
  final String id;
  final String audioUrl;
  final int duration;
  final String oderId;
  final DateTime actionAt;
  final DateTime takenAt;
  final int baseExp;
  final int bonusExp;
  final String text;
  final String mood;
  final DateTime createdAt;
  final bool isPinned;

  const Voice({
    required this.id,
    required this.audioUrl,
    required this.duration,
    required this.oderId,
    required this.actionAt,
    required this.takenAt,
    required this.baseExp,
    required this.bonusExp,
    required this.text,
    required this.mood,
    required this.createdAt,
    this.isPinned = false,
  });

  Voice copyWith({
    String? id,
    String? audioUrl,
    int? duration,
    String? oderId,
    DateTime? actionAt,
    DateTime? takenAt,
    int? baseExp,
    int? bonusExp,
    String? text,
    String? mood,
    DateTime? createdAt,
    bool? isPinned,
  }) {
    return Voice(
      id: id ?? this.id,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      oderId: oderId ?? this.oderId,
      actionAt: actionAt ?? this.actionAt,
      takenAt: takenAt ?? this.takenAt,
      baseExp: baseExp ?? this.baseExp,
      bonusExp: bonusExp ?? this.bonusExp,
      text: text ?? this.text,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  List<Object?> get props => [
    id,
    audioUrl,
    duration,
    oderId,
    actionAt,
    takenAt,
    baseExp,
    bonusExp,
    text,
    mood,
    createdAt,
    isPinned,
  ];
}

class VoiceList extends Equatable {
  final List<Voice> items;
  final int total;

  const VoiceList({required this.items, required this.total});

  @override
  List<Object?> get props => [items, total];
}
