/// DTO cho response khi gửi ảnh cho pet
class SendImageToPetResponseDto {
  final int expAdded; // Tổng EXP nhận được
  final int bonus; // Bonus EXP (20 nếu partner gửi trong 3h, 0 nếu không)
  final bool levelUp; // true nếu pet lên level
  final String actionId; // ID của action vừa tạo

  SendImageToPetResponseDto({
    required this.expAdded,
    required this.bonus,
    required this.levelUp,
    required this.actionId,
  });

  factory SendImageToPetResponseDto.fromJson(Map<String, dynamic> json) {
    return SendImageToPetResponseDto(
      expAdded: json['expAdded'] ?? 0,
      bonus: json['bonus'] ?? 0,
      levelUp: json['levelUp'] ?? false,
      actionId: json['actionId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expAdded': expAdded,
      'bonus': bonus,
      'levelUp': levelUp,
      'actionId': actionId,
    };
  }
}

