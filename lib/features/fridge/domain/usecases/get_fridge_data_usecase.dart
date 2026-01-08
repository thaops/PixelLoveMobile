import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/fridge/domain/entities/fridge.dart';
import 'package:pixel_love/features/fridge/domain/repositories/fridge_repository.dart';

class GetFridgeDataUseCase {
  final FridgeRepository _repository;

  GetFridgeDataUseCase(this._repository);

  Future<ApiResult<Fridge>> call() {
    return _repository.getFridgeData();
  }
}

