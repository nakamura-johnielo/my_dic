import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';

abstract interface class IWatchEspJpnWordStatusUsecase {
  Stream<WordStatus> execute(int wordId);
}

class WatchEspJpnWordStatusInteractor implements IWatchEspJpnWordStatusUsecase {
  WatchEspJpnWordStatusInteractor(this._repository, this._currentSession);

  final IWordStatusRepository _repository;
  final CurrentSession _currentSession;

  @override
  Stream<WordStatus> execute(int wordId) => _repository.watchWordStatusById(
        wordId,
        accountId: _currentSession.accountIdOrNull ?? guestAccountScope,
      );
}
