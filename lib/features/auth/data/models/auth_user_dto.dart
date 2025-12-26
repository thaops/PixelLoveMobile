import 'package:pixel_love/features/auth/domain/entities/auth_user.dart';

class AuthUserDto {
  final String id;
  final String? name;
  final String? email;
  final String? avatar;
  final String? dob;
  final String? zodiac;
  final String mode;
  final String? coupleCode;
  final String? coupleRoomId;
  final String? partnerId;
  final bool isOnboarded;
  final int coins;
  final String accessToken;

  AuthUserDto({
    required this.id,
    this.name,
    this.email,
    this.avatar,
    this.dob,
    this.zodiac,
    required this.mode,
    this.coupleCode,
    this.coupleRoomId,
    this.partnerId,
    this.isOnboarded = false,
    required this.coins,
    required this.accessToken,
  });

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    String? partnerId;

    if (json['partnerId'] != null && json['partnerId'].toString().isNotEmpty) {
      partnerId = json['partnerId'].toString();
    } else if (json['couple'] != null && json['couple'] is Map) {
      final couple = json['couple'] as Map<String, dynamic>;
      final partners = couple['partners'] as List?;
      if (partners != null && partners.isNotEmpty) {
        final currentUserId = json['id'] ?? json['_id'] ?? '';
        for (var partner in partners) {
          if (partner is Map) {
            final partnerIdStr = partner['id']?.toString();
            if (partnerIdStr != null && partnerIdStr != currentUserId) {
              partnerId = partnerIdStr;
              break;
            }
          }
        }
      }
    }

    final coupleRoomId =
        json['coupleRoomId']?.toString() ?? json['coupleId']?.toString();

    final accessToken =
        json['accessToken'] ?? json['access_token'] ?? json['token'] ?? '';

    final name = json['nickname'] ?? json['displayName'] ?? json['name'];
    final avatar = json['avatarUrl'] ?? json['avatar'];
    final dob = json['birthDate']?.toString() ?? json['dob']?.toString();

    return AuthUserDto(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: name?.toString(),
      email: json['email']?.toString(),
      avatar: avatar?.toString(),
      dob: dob,
      zodiac: json['zodiac']?.toString(),
      mode: json['mode']?.toString() ?? 'solo',
      coupleCode: json['coupleCode']?.toString(),
      coupleRoomId: coupleRoomId,
      partnerId: partnerId,
      isOnboarded: json['isOnboarded'] == true,
      coins: (json['coins'] is int)
          ? json['coins'] as int
          : (json['coins'] is String)
          ? int.tryParse(json['coins']) ?? 0
          : 0,
      accessToken: accessToken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'dob': dob,
      'zodiac': zodiac,
      'mode': mode,
      'coupleCode': coupleCode,
      'coupleRoomId': coupleRoomId,
      'partnerId': partnerId,
      'isOnboarded': isOnboarded,
      'coins': coins,
      'accessToken': accessToken,
    };
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      name: name,
      email: email,
      avatar: avatar,
      dob: dob,
      zodiac: zodiac,
      mode: mode,
      coupleCode: coupleCode,
      coupleRoomId: coupleRoomId,
      partnerId: partnerId,
      isOnboarded: isOnboarded,
      coins: coins,
      accessToken: accessToken,
    );
  }
}
