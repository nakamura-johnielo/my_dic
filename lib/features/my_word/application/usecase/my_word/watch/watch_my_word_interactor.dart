import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/features/my_word/application/usecase/my_word/watch/watch_my_word_usecase.dart';

class WatchMyWordInteractor implements WatchMyWordUsecase {
  final IMyWordRepository _repository;
  final CurrentSession _currentSession;

  WatchMyWordInteractor(this._repository, this._currentSession);

  @override
  Stream<MyWord> execute(String wordId) {
    final scope = _currentSession.accountIdOrNull ?? guestAccountScope;
    return _repository.watchMyWord(wordId, accountId: scope);
  }
}
