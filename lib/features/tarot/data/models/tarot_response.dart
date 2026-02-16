import 'package:equatable/equatable.dart';

enum TarotStatus {
  IDLE,
  WAITING,
  READY,
  REVEALED;

  static TarotStatus fromString(String status) {
    return TarotStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => TarotStatus.IDLE,
    );
  }
}

class TarotResult extends Equatable {
  final int cardA;
  final int cardB;
  final String text;
  final String question;
  final int? streak;

  const TarotResult({
    required this.cardA,
    required this.cardB,
    required this.text,
    required this.question,
    this.streak,
  });

  factory TarotResult.fromJson(Map<String, dynamic> json) {
    return TarotResult(
      cardA: json['cardA'] ?? 0,
      cardB: json['cardB'] ?? 0,
      text: json['text'] ?? '',
      question: json['question'] ?? '',
      streak: json['streak'],
    );
  }

  @override
  List<Object?> get props => [cardA, cardB, text, question, streak];
}

class TarotResponse extends Equatable {
  final String? date;
  final TarotStatus status;
  final int? myCard;
  final bool partnerSelected;
  final String? partnerId;
  final TarotResult? result;

  const TarotResponse({
    this.date,
    required this.status,
    this.myCard,
    this.partnerSelected = false,
    this.partnerId,
    this.result,
  });

  factory TarotResponse.fromJson(Map<String, dynamic> json) {
    return TarotResponse(
      date: json['date'],
      status: TarotStatus.fromString(json['status'] ?? 'IDLE'),
      myCard: json['myCard'],
      partnerSelected: json['partnerSelected'] ?? false,
      partnerId: json['partnerId'],
      result: json['result'] != null
          ? TarotResult.fromJson(json['result'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    date,
    status,
    myCard,
    partnerSelected,
    partnerId,
    result,
  ];
}
