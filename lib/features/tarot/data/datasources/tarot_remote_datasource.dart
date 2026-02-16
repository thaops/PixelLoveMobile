import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/tarot/data/models/tarot_response.dart';

abstract class TarotRemoteDataSource {
  Future<ApiResult<TarotResponse>> getTodayTarot();
  Future<ApiResult<TarotResponse>> selectCard(int cardId);
  Future<ApiResult<TarotResult>> revealTarot();
}

class TarotRemoteDataSourceImpl implements TarotRemoteDataSource {
  final DioApi _dioApi;

  TarotRemoteDataSourceImpl(this._dioApi);

  @override
  Future<ApiResult<TarotResponse>> getTodayTarot() {
    return _dioApi.get(
      '/tarot/today',
      fromJson: (json) => TarotResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<TarotResponse>> selectCard(int cardId) {
    return _dioApi.post(
      '/tarot/select',
      data: {'cardId': cardId},
      fromJson: (json) => TarotResponse.fromJson(json),
    );
  }

  @override
  Future<ApiResult<TarotResult>> revealTarot() {
    return _dioApi.post(
      '/tarot/reveal',
      fromJson: (json) => TarotResult.fromJson(json),
    );
  }
}
