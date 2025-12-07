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
    required this.coins,
    required this.accessToken,
  });

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    return AuthUserDto(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      dob: json['dob'],
      zodiac: json['zodiac'],
      mode: json['mode'] ?? 'solo',
      coupleCode: json['coupleCode'],
      coupleRoomId: json['coupleRoomId'],
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
      coins: coins,
      accessToken: accessToken,
    );
  }
}
