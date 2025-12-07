import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/couple/domain/entities/partner_preview.dart';
import 'package:pixel_love/features/couple/domain/repositories/couple_repository.dart';

class PreviewCodeUseCase {
  final CoupleRepository _repository;

  PreviewCodeUseCase(this._repository);

  Future<ApiResult<PartnerPreview>> call(String code) async {
    return await _repository.previewCode(code);
  }
}

