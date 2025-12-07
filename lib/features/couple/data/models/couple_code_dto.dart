class CoupleCodeDto {
  final String coupleCode;
  final String expiresAt;
  final String message;

  CoupleCodeDto({
    required this.coupleCode,
    required this.expiresAt,
    required this.message,
  });

  factory CoupleCodeDto.fromJson(Map<String, dynamic> json) {
    return CoupleCodeDto(
      coupleCode: json['coupleCode'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

