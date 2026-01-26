import 'package:my_dic/features/my_word/domain/entity/my_word_status.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/watch_my_word_status/watch_my_word_status_usecase.dart';

class WatchMyWordStatusInteractor implements WatchMyWordStatusUsecase {
  final IMyWordStatusRepository _repository;

  WatchMyWordStatusInteractor(this._repository);

  @override
  Stream<MyWordStatus> execute(String wordId) {
    return _repository.watchStatus(wordId);
  }
}
