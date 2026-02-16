import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/tarot/data/models/tarot_response.dart';

abstract class TarotRepository {
  Future<ApiResult<TarotResponse>> getTodayTarot();
  Future<ApiResult<TarotResponse>> selectCard(int cardId);
  Future<ApiResult<TarotResult>> revealTarot();
}
