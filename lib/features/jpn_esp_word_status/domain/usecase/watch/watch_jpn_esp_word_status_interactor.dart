
import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/i_jpn_esp_word_status_repository.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/watch/i_watch_jpn_esp_word_status_usecase.dart';

class WatchJpnEspWordStatusInteractor implements IWatchJpnEspWordStatusUsecase{
  final IJpnEspWordStatusRepository _repository;
  final CurrentSession _currentSession;

  WatchJpnEspWordStatusInteractor(this._repository, this._currentSession);

  @override
  Stream<JpnEspWordStatus> execute(int wordId) {
    final scope = _currentSession.accountIdOrNull ?? guestAccountScope;
    return _repository.watchWordStatusById(wordId, accountId: scope);
  }
}
