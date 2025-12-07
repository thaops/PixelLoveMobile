import 'package:pixel_love/features/auth/domain/entities/auth_user.dart';

class PartnerPreview {
  final AuthUser? partner;
  final bool codeValid;
  final bool canPair;
  final String? message;

  PartnerPreview({
    this.partner,
    required this.codeValid,
    required this.canPair,
    this.message,
  });
}

