import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/internal/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/watch/watch_my_word_usecase.dart';

class WatchMyWordInteractor implements WatchMyWordUsecase {
  final IMyWordRepository _repository;
  WatchMyWordInteractor(this._repository);

  @override
  Stream<MyWord> execute(String wordId, String accountScope) {
    return _repository.watchMyWord(wordId, accountId: accountScope);
  }
}
