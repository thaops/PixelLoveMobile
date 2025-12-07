import 'package:pixel_love/features/user/domain/entities/user.dart';

class UserDto {
  final String id;
  final String? name;
  final String? avatar;
  final String? email;
  final String? phone;
  final String? dob;
  final String? zodiac;
  final String mode;
  final String? coupleCode;
  final String? coupleRoomId;
  final int coins;
  final String? createdAt;

  UserDto({
    required this.id,
    this.name,
    this.avatar,
    this.email,
    this.phone,
    this.dob,
    this.zodiac,
    required this.mode,
    this.coupleCode,
    this.coupleRoomId,
    required this.coins,
    this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'],
      avatar: json['avatar'],
      email: json['email'],
      phone: json['phone'],
      dob: json['dob'],
      zodiac: json['zodiac'],
      mode: json['mode'] ?? 'solo',
      coupleCode: json['coupleCode'],
      coupleRoomId: json['coupleRoomId'],
      coins: json['coins'] ?? 0,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'email': email,
      'phone': phone,
      'dob': dob,
      'zodiac': zodiac,
      'mode': mode,
      'coupleCode': coupleCode,
      'coupleRoomId': coupleRoomId,
      'coins': coins,
      'createdAt': createdAt,
    };
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      avatar: avatar,
      email: email,
      phone: phone,
      dob: dob,
      zodiac: zodiac,
      mode: mode,
      coupleCode: coupleCode,
      coupleRoomId: coupleRoomId,
      coins: coins,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }

  factory UserDto.fromEntity(User user) {
    return UserDto(
      id: user.id,
      name: user.name,
      avatar: user.avatar,
      email: user.email,
      phone: user.phone,
      dob: user.dob,
      zodiac: user.zodiac,
      mode: user.mode,
      coupleCode: user.coupleCode,
      coupleRoomId: user.coupleRoomId,
      coins: user.coins,
      createdAt: user.createdAt?.toIso8601String(),
    );
  }
}
