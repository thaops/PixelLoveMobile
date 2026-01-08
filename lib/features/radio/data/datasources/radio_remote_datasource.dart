import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/radio/data/models/voice_dto.dart';

class SendVoiceResponseDto {
  final int expAdded;
  final int bonus;
  final bool levelUp;
  final String actionId;

  SendVoiceResponseDto({
    required this.expAdded,
    required this.bonus,
    required this.levelUp,
    required this.actionId,
  });

  factory SendVoiceResponseDto.fromJson(Map<String, dynamic> json) {
    return SendVoiceResponseDto(
      expAdded: json['expAdded'] as int? ?? 0,
      bonus: json['bonus'] as int? ?? 0,
      levelUp: json['levelUp'] as bool? ?? false,
      actionId: json['actionId'] as String? ?? '',
    );
  }
}

abstract class RadioRemoteDataSource {
  Future<ApiResult<VoiceListDto>> getVoices({int page = 1, int limit = 20});
  Future<ApiResult<SendVoiceResponseDto>> sendVoice({
    required String audioUrl,
    required int duration,
    required DateTime takenAt,
    required String text,
    required String mood,
  });
}

class RadioRemoteDataSourceImpl implements RadioRemoteDataSource {
  final DioApi _dioApi;

  RadioRemoteDataSourceImpl(this._dioApi);

  @override
  Future<ApiResult<VoiceListDto>> getVoices({
    int page = 1,
    int limit = 20,
  }) async {
    return await _dioApi.get(
      '/pet/voices',
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) => VoiceListDto.fromJson(json),
    );
  }

  @override
  Future<ApiResult<SendVoiceResponseDto>> sendVoice({
    required String audioUrl,
    required int duration,
    required DateTime takenAt,
    required String text,
    required String mood,
  }) async {
    return await _dioApi.post(
      '/pet/voice',
      data: {
        'audioUrl': audioUrl,
        'duration': duration,
        'takenAt': takenAt.toIso8601String(),
        'text': text,
        'mood': mood,
      },
      fromJson: (json) => SendVoiceResponseDto.fromJson(json),
    );
  }
}
