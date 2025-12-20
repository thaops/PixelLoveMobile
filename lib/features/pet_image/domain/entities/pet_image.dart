import 'package:equatable/equatable.dart';

/// Entity đại diện cho một ảnh đã gửi cho pet
class PetImage extends Equatable {
  final String imageUrl;
  final String userId;
  final DateTime actionAt; // Thời điểm gửi ảnh
  final DateTime? takenAt; // Thời điểm chụp ảnh (optional)
  final int baseExp; // EXP cơ bản
  final int bonusExp; // EXP bonus (0 hoặc 20)
  final String? mood; // Tâm trạng pet (optional)
  final String? text; // Caption (optional)
  final DateTime createdAt; // Timestamp tạo record

  const PetImage({
    required this.imageUrl,
    required this.userId,
    required this.actionAt,
    this.takenAt,
    required this.baseExp,
    required this.bonusExp,
    this.mood,
    this.text,
    required this.createdAt,
  });

  /// Tổng EXP nhận được
  int get totalExp => baseExp + bonusExp;

  /// Có bonus EXP không
  bool get hasBonus => bonusExp > 0;

  @override
  List<Object?> get props => [
        imageUrl,
        userId,
        actionAt,
        takenAt,
        baseExp,
        bonusExp,
        mood,
        text,
        createdAt,
      ];
}

