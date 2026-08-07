import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';

abstract interface class FetchEspJpnWordStatusUsecase {
  Future<Result<WordStatus>> execute(int wordId);
  Stream<WordStatus> watch(int wordId);
}

class FetchEspJpnWordStatusInteractor implements FetchEspJpnWordStatusUsecase {
  FetchEspJpnWordStatusInteractor(this._repository, this._currentSession);

  final IWordStatusRepository _repository;
  final CurrentSession _currentSession;

  String get _scope => _currentSession.accountIdOrNull ?? guestAccountScope;

  @override
  Future<Result<WordStatus>> execute(int wordId) async {
    final result = await _repository.getWordStatusById(wordId, accountId: _scope);
    return result.map((data) => data ?? WordStatus(wordId: wordId));
  }

  @override
  Stream<WordStatus> watch(int wordId) =>
      _repository.watchWordStatusById(wordId, accountId: _scope);
}
