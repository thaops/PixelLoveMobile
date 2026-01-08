import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/radio/data/datasources/radio_remote_datasource.dart';
import 'package:pixel_love/features/radio/domain/entities/voice.dart';
import 'package:pixel_love/features/radio/domain/repositories/radio_repository.dart';

class RadioRepositoryImpl implements RadioRepository {
  final RadioRemoteDataSource _remoteDataSource;

  RadioRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<VoiceList>> getVoices({int page = 1, int limit = 20}) async {
    final result = await _remoteDataSource.getVoices(page: page, limit: limit);

    return result.when(
      success: (dto) => ApiResult.success(dto.toEntity()),
      error: (error) => ApiResult.error(error),
    );
  }
}
