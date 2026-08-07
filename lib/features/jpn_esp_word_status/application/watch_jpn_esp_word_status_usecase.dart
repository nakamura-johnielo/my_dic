import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/i_jpn_esp_word_status_repository.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart';

abstract interface class IWatchJpnEspWordStatusUsecase {
  Stream<JpnEspWordStatus> execute(int wordId);
}

class WatchJpnEspWordStatusInteractor implements IWatchJpnEspWordStatusUsecase {
  WatchJpnEspWordStatusInteractor(this._repository, this._currentSession);

  final IJpnEspWordStatusRepository _repository;
  final CurrentSession _currentSession;

  @override
  Stream<JpnEspWordStatus> execute(int wordId) => _repository.watchWordStatusById(
        wordId,
        accountId: _currentSession.accountIdOrNull ?? guestAccountScope,
      );
}
