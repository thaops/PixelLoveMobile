class CouplePairResponseDto {
  final String message;
  final String? coupleRoomId;
  final String? partnerId;

  CouplePairResponseDto({
    required this.message,
    this.coupleRoomId,
    this.partnerId,
  });

  factory CouplePairResponseDto.fromJson(Map<String, dynamic> json) {
    return CouplePairResponseDto(
      message: json['message'] ?? '',
      coupleRoomId: json['coupleRoomId'],
      partnerId: json['partnerId'],
    );
  }
}

