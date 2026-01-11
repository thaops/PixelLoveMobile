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

class PinVoiceResponseDto {
  final bool success;
  final String voiceId;
  final bool isPinned;

  PinVoiceResponseDto({
    required this.success,
    required this.voiceId,
    required this.isPinned,
  });

  factory PinVoiceResponseDto.fromJson(Map<String, dynamic> json) {
    return PinVoiceResponseDto(
      success: json['success'] as bool? ?? false,
      voiceId: json['voiceId'] as String? ?? '',
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }
}

class DeleteVoiceResponseDto {
  final bool success;

  DeleteVoiceResponseDto({required this.success});

  factory DeleteVoiceResponseDto.fromJson(Map<String, dynamic> json) {
    return DeleteVoiceResponseDto(success: json['success'] as bool? ?? false);
  }
}

abstract class RadioRemoteDataSource {
  Future<ApiResult<VoiceListDto>> getVoices({int page = 1, int limit = 20});
  Future<ApiResult<VoiceDto?>> getPinnedVoice();
  Future<ApiResult<SendVoiceResponseDto>> sendVoice({
    required String audioUrl,
    required int duration,
    required DateTime takenAt,
    required String text,
    required String mood,
  });
  Future<ApiResult<DeleteVoiceResponseDto>> deleteVoice(String voiceId);
  Future<ApiResult<PinVoiceResponseDto>> pinVoice(String voiceId);
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

  @override
  Future<ApiResult<DeleteVoiceResponseDto>> deleteVoice(String voiceId) async {
    return await _dioApi.delete(
      '/pet/voices/$voiceId',
      fromJson: (json) => DeleteVoiceResponseDto.fromJson(json),
    );
  }

  @override
  Future<ApiResult<PinVoiceResponseDto>> pinVoice(String voiceId) async {
    return await _dioApi.post(
      '/pet/voices/pin',
      data: {'voiceId': voiceId},
      fromJson: (json) => PinVoiceResponseDto.fromJson(json),
    );
  }

  @override
  Future<ApiResult<VoiceDto?>> getPinnedVoice() async {
    return await _dioApi.get(
      '/pet/voices/pinned',
      fromJson: (json) {
        if (json == null || (json is Map && json.isEmpty)) {
          return null;
        }
        return VoiceDto.fromJson(json);
      },
    );
  }
}
