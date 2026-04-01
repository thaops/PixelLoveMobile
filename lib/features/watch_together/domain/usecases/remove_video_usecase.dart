import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/watch_together/domain/repositories/watch_together_repository.dart';

class RemoveVideoUsecase {
  final WatchTogetherRepository _repository;

  RemoveVideoUsecase(this._repository);

  Future<ApiResult<bool>> call(String itemId) {
    return _repository.removeVideo(itemId);
  }
}