import 'package:pixel_love/features/pet_image/domain/entities/pet_image.dart';

/// Base class cho các item trong timeline
sealed class TimelineItem {}

/// Header hiển thị mốc thời gian
class TimeHeader extends TimelineItem {
  final DateTime time;

  TimeHeader(this.time);
}

/// Item ảnh từ một user
class ImageItem extends TimelineItem {
  final PetImage image;
  final bool isMe; // true = Tôi, false = Người ấy
  final String? userName;
  final String? userAvatar;
  final String gender; // 'male' hoặc 'female'

  ImageItem({
    required this.image,
    required this.isMe,
    this.userName,
    this.userAvatar,
    required this.gender,
  });
}

/// Combo event - cả hai cùng chăm pet
class ComboItem extends TimelineItem {
  final List<PetImage> images; // 2 images từ 2 users
  final int totalExp; // Tổng EXP của combo
  final DateTime time; // Thời điểm combo

  ComboItem({required this.images, required this.totalExp, required this.time});
}
