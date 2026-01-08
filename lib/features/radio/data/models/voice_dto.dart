import 'package:pixel_love/features/radio/domain/entities/voice.dart';

class VoiceDto {
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

  VoiceDto({
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

  factory VoiceDto.fromJson(Map<String, dynamic> json) {
    return VoiceDto(
      audioUrl: json['audioUrl'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      userId: json['userId'] as String? ?? '',
      actionAt:
          DateTime.tryParse(json['actionAt'] as String? ?? '') ??
          DateTime.now(),
      takenAt:
          DateTime.tryParse(json['takenAt'] as String? ?? '') ?? DateTime.now(),
      baseExp: json['baseExp'] as int? ?? 0,
      bonusExp: json['bonusExp'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      mood: json['mood'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Voice toEntity() {
    return Voice(
      audioUrl: audioUrl,
      duration: duration,
      userId: userId,
      actionAt: actionAt,
      takenAt: takenAt,
      baseExp: baseExp,
      bonusExp: bonusExp,
      text: text,
      mood: mood,
      createdAt: createdAt,
    );
  }
}

class VoiceListDto {
  final List<VoiceDto> items;
  final int total;

  VoiceListDto({required this.items, required this.total});

  factory VoiceListDto.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return VoiceListDto(
      items: itemsList
          .map((item) => VoiceDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }

  VoiceList toEntity() {
    return VoiceList(
      items: items.map((dto) => dto.toEntity()).toList(),
      total: total,
    );
  }
}
