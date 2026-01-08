import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/radio/domain/entities/voice.dart';
import 'package:pixel_love/features/radio/domain/repositories/radio_repository.dart';

class GetVoicesUseCase {
  final RadioRepository _repository;

  GetVoicesUseCase(this._repository);

  Future<ApiResult<VoiceList>> call({int page = 1, int limit = 20}) {
    return _repository.getVoices(page: page, limit: limit);
  }
}
