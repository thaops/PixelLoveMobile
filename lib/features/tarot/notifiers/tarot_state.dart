import 'package:equatable/equatable.dart';
import 'package:pixel_love/features/tarot/data/models/tarot_response.dart';

class TarotState extends Equatable {
  final bool isLoading;
  final TarotStatus status;
  final int? myCard;
  final bool partnerSelected;
  final TarotResult? result;
  final String? errorMessage;
  final int countdown;

  const TarotState({
    this.isLoading = false,
    this.status = TarotStatus.IDLE,
    this.myCard,
    this.partnerSelected = false,
    this.result,
    this.errorMessage,
    this.countdown = 0,
  });

  TarotState copyWith({
    bool? isLoading,
    TarotStatus? status,
    int? myCard,
    bool? partnerSelected,
    TarotResult? result,
    String? errorMessage,
    int? countdown,
  }) {
    return TarotState(
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      myCard: myCard ?? this.myCard,
      partnerSelected: partnerSelected ?? this.partnerSelected,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      countdown: countdown ?? this.countdown,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    status,
    myCard,
    partnerSelected,
    result,
    errorMessage,
    countdown,
  ];
}
