import 'package:pixel_love/features/watch_together/domain/repositories/watch_together_repository.dart';

class SendEndedUsecase {
  final WatchTogetherRepository _repository;

  SendEndedUsecase(this._repository);

  void call() {
    _repository.sendEnded();
  }
}