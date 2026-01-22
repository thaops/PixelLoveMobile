import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/couple/data/models/couple_code_dto.dart';
import 'package:pixel_love/features/couple/data/models/couple_pair_response_dto.dart';
import 'package:pixel_love/features/couple/data/models/partner_preview_dto.dart';

abstract class CoupleRemoteDataSource {
  Future<ApiResult<CoupleCodeDto>> createCode();
  Future<ApiResult<PartnerPreviewDto>> previewCode(String code);
  Future<ApiResult<CouplePairResponseDto>> pairCouple(String code);
  Future<ApiResult<Map<String, dynamic>>> getCoupleInfo();
  Future<ApiResult<void>> breakUp();
}

class CoupleRemoteDataSourceImpl implements CoupleRemoteDataSource {
  final DioApi _dioApi;

  CoupleRemoteDataSourceImpl(this._dioApi);

  @override
  Future<ApiResult<CoupleCodeDto>> createCode() async {
    return await _dioApi.post(
      '/couple/create-code',
      fromJson: (json) => CoupleCodeDto.fromJson(json),
    );
  }

  @override
  Future<ApiResult<PartnerPreviewDto>> previewCode(String code) async {
    return await _dioApi.get(
      '/couple/preview',
      queryParameters: {'code': code},
      fromJson: (json) => PartnerPreviewDto.fromJson(json),
    );
  }

  @override
  Future<ApiResult<CouplePairResponseDto>> pairCouple(String code) async {
    return await _dioApi.post(
      '/couple/pair',
      data: {'code': code},
      fromJson: (json) => CouplePairResponseDto.fromJson(json),
    );
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> getCoupleInfo() async {
    return await _dioApi.get(
      '/couple/info',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<ApiResult<void>> breakUp() async {
    return await _dioApi.post(
      '/couple/break-up',
      data: {},
      fromJson: (json) {},
    );
  }
}
