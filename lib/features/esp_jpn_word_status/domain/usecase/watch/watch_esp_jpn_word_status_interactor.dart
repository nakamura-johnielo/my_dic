
import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/watch/i_watch_esp_jpn_word_status_usecase.dart';

class WatchEspJpnWordStatusInteractor implements IWatchEspJpnWordStatusUsecase{
  final IWordStatusRepository _repository;
  final CurrentSession _currentSession;

  WatchEspJpnWordStatusInteractor(this._repository, this._currentSession);

  @override
  Stream<WordStatus> execute(int wordId) {
    final scope = _currentSession.accountIdOrNull ?? guestAccountScope;
    return _repository.watchWordStatusById(wordId, accountId: scope);
  }
}
