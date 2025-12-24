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
    // Parse partnerId từ nhiều nguồn có thể
    String? partnerId;

    // Nguồn 1: partnerId ở root (backend đã làm sẵn)
    if (json['partnerId'] != null) {
      partnerId = json['partnerId'] as String;
    }
    // Nguồn 2: Parse từ couple.partners[] (nếu backend chưa có partnerId)
    else if (json['couple'] != null && json['couple'] is Map) {
      final couple = json['couple'] as Map<String, dynamic>;
      final partners = couple['partners'] as List?;
      if (partners != null && partners.isNotEmpty) {
        // Lấy partner khác (không phải chính mình)
        final currentUserId = json['id'] ?? json['_id'] ?? '';
        for (var partner in partners) {
          if (partner is Map && partner['id'] != currentUserId) {
            partnerId = partner['id'] as String?;
            break;
          }
        }
      }
    }

    // Map couple id from multiple possible keys
    final coupleRoomId = json['coupleRoomId'] ?? json['coupleId'];

    return AuthUserDto(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['displayName'] ?? json['name'] ?? json['nickname'],
      email: json['email'],
      avatar: json['avatarUrl'] ?? json['avatar'],
      dob: json['birthDate'] ?? json['dob'],
      zodiac: json['zodiac'],
      mode: json['mode'] ?? 'solo',
      coupleCode: json['coupleCode'],
      coupleRoomId: coupleRoomId,
      partnerId: partnerId,
      isOnboarded: json['isOnboarded'] ?? false,
      coins: json['coins'] ?? 0,
      accessToken: json['token'] ?? json['access_token'] ?? '',
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
