import 'package:pixel_love/features/auth/data/models/auth_user_dto.dart';

class PartnerPreviewDto {
  final AuthUserDto? partner;
  final bool codeValid;
  final bool canPair;
  final String? message;

  PartnerPreviewDto({
    this.partner,
    required this.codeValid,
    required this.canPair,
    this.message,
  });

  factory PartnerPreviewDto.fromJson(Map<String, dynamic> json) {
    return PartnerPreviewDto(
      partner: json['partner'] != null
          ? AuthUserDto.fromJson(json['partner'])
          : null,
      codeValid: json['codeValid'] ?? false,
      canPair: json['canPair'] ?? false,
      message: json['message'],
    );
  }
}

