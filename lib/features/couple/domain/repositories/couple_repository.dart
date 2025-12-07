import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/couple/domain/entities/couple_code.dart';
import 'package:pixel_love/features/couple/domain/entities/couple_pair_response.dart';
import 'package:pixel_love/features/couple/domain/entities/partner_preview.dart';

abstract class CoupleRepository {
  Future<ApiResult<CoupleCode>> createCode();
  Future<ApiResult<PartnerPreview>> previewCode(String code);
  Future<ApiResult<CouplePairResponse>> pairCouple(String code);
  Future<ApiResult<Map<String, dynamic>>> getCoupleInfo();
}

