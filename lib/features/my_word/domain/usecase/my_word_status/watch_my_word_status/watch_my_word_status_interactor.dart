import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word_status.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/watch_my_word_status/watch_my_word_status_usecase.dart';

class WatchMyWordStatusInteractor implements WatchMyWordStatusUsecase {
  final IMyWordStatusRepository _repository;
  final CurrentSession _currentSession;

  WatchMyWordStatusInteractor(this._repository, this._currentSession);

  @override
  Stream<MyWordStatus> execute(String wordId) {
    final scope = _currentSession.accountIdOrNull ?? guestAccountScope;
    return _repository.watchStatus(wordId, accountId: scope);
  }
}
