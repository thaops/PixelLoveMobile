import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/couple/data/datasources/couple_remote_datasource.dart';
import 'package:pixel_love/features/couple/domain/entities/couple_code.dart';
import 'package:pixel_love/features/couple/domain/entities/couple_pair_response.dart';
import 'package:pixel_love/features/couple/domain/entities/partner_preview.dart';
import 'package:pixel_love/features/couple/domain/repositories/couple_repository.dart';

class CoupleRepositoryImpl implements CoupleRepository {
  final CoupleRemoteDataSource _remoteDataSource;

  CoupleRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<CoupleCode>> createCode() async {
    final result = await _remoteDataSource.createCode();
    return result.when(
      success: (dto) {
        final entity = CoupleCode(
          code: dto.coupleCode,
          expiresAt: DateTime.parse(dto.expiresAt),
          message: dto.message,
        );
        return ApiResult.success(entity);
      },
      error: (error) => ApiResult.error(error),
    );
  }

  @override
  Future<ApiResult<PartnerPreview>> previewCode(String code) async {
    final result = await _remoteDataSource.previewCode(code);
    return result.when(
      success: (dto) {
        final entity = PartnerPreview(
          partner: dto.partner?.toEntity(),
          codeValid: dto.codeValid,
          canPair: dto.canPair,
          message: dto.message,
        );
        return ApiResult.success(entity);
      },
      error: (error) => ApiResult.error(error),
    );
  }

  @override
  Future<ApiResult<CouplePairResponse>> pairCouple(String code) async {
    final result = await _remoteDataSource.pairCouple(code);
    return result.when(
      success: (dto) {
        final entity = CouplePairResponse(
          message: dto.message,
          coupleRoomId: dto.coupleRoomId,
          partnerId: dto.partnerId,
        );
        return ApiResult.success(entity);
      },
      error: (error) => ApiResult.error(error),
    );
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> getCoupleInfo() async {
    return await _remoteDataSource.getCoupleInfo();
  }
}

