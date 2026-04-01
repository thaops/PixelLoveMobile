import 'package:pixel_love/features/watch_together/domain/repositories/watch_together_repository.dart';

class NextVideoUsecase {
  final WatchTogetherRepository _repository;

  NextVideoUsecase(this._repository);

  void call() {
    _repository.nextVideo();
  }
}