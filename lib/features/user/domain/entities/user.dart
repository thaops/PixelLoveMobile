import 'package:equatable/equatable.dart';

class User extends Equatable {
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
  final DateTime? createdAt;

  const User({
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

  User copyWith({
    String? name,
    String? avatar,
    String? email,
    String? phone,
    String? dob,
    String? zodiac,
    String? mode,
    String? coupleCode,
    String? coupleRoomId,
    int? coins,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      zodiac: zodiac ?? this.zodiac,
      mode: mode ?? this.mode,
      coupleCode: coupleCode ?? this.coupleCode,
      coupleRoomId: coupleRoomId ?? this.coupleRoomId,
      coins: coins ?? this.coins,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        avatar,
        email,
        phone,
        dob,
        zodiac,
        mode,
        coupleCode,
        coupleRoomId,
        coins,
        createdAt,
      ];
}
