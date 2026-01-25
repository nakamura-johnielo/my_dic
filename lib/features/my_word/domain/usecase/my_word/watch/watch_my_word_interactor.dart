import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/watch/watch_my_word_usecase.dart';


class WatchMyWordInteractor implements WatchMyWordUsecase {
  final IMyWordRepository _repository;

  WatchMyWordInteractor(this._repository);

  @override
  Stream<MyWord> execute(int wordId) {
    return _repository.watchMyWord(wordId);
  }
}
