import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
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

  const AuthUser({
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

  AuthUser copyWith({
    String? name,
    String? email,
    String? avatar,
    String? dob,
    String? zodiac,
    String? mode,
    String? coupleCode,
    String? coupleRoomId,
    String? partnerId,
    bool? isOnboarded,
    int? coins,
  }) {
    return AuthUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      dob: dob ?? this.dob,
      zodiac: zodiac ?? this.zodiac,
      mode: mode ?? this.mode,
      coupleCode: coupleCode ?? this.coupleCode,
      coupleRoomId: coupleRoomId ?? this.coupleRoomId,
      partnerId: partnerId ?? this.partnerId,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      coins: coins ?? this.coins,
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

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? '',
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      dob: json['dob'],
      zodiac: json['zodiac'],
      mode: json['mode'] ?? 'solo',
      coupleCode: json['coupleCode'],
      coupleRoomId: json['coupleRoomId'],
      partnerId: json['partnerId'],
      isOnboarded: json['isOnboarded'] ?? false,
      coins: json['coins'] ?? 0,
      accessToken: json['accessToken'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        avatar,
        dob,
        zodiac,
        mode,
        coupleCode,
        coupleRoomId,
        partnerId,
        isOnboarded,
        coins,
        accessToken,
      ];
}
