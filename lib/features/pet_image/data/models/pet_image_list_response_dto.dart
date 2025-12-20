import 'package:pixel_love/features/pet_image/data/models/pet_image_dto.dart';

/// DTO cho response danh sách ảnh pet
class PetImageListResponseDto {
  final List<PetImageDto> items;
  final int total;

  PetImageListResponseDto({
    required this.items,
    required this.total,
  });

  factory PetImageListResponseDto.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return PetImageListResponseDto(
      items: itemsList
          .map((item) => PetImageDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
    };
  }
}

