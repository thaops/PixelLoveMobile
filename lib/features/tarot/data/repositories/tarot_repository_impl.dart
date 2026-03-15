import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/tarot/data/datasources/tarot_remote_datasource.dart';
import 'package:pixel_love/features/tarot/data/models/tarot_response.dart';
import 'package:pixel_love/features/tarot/domain/repositories/tarot_repository.dart';

class TarotRepositoryImpl implements TarotRepository {
  final TarotRemoteDataSource _remoteDataSource;

  TarotRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<TarotResponse>> getTodayTarot() {
    return _remoteDataSource.getTodayTarot();
  }

  @override
  Future<ApiResult<TarotResponse>> selectCard(int cardId) {
    return _remoteDataSource.selectCard(cardId);
  }

  @override
  Future<ApiResult<TarotResult>> revealTarot() {
    return _remoteDataSource.revealTarot();
  }

  @override
  Future<ApiResult<void>> resetTarot() {
    return _remoteDataSource.resetTarot();
  }
}
