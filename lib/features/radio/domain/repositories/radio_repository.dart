import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/radio/domain/entities/voice.dart';

abstract class RadioRepository {
  Future<ApiResult<VoiceList>> getVoices({int page = 1, int limit = 20});
}
