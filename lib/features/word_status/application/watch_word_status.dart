import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/word_status/application/port/word_status_repository.dart';
import 'package:my_dic/features/word_status/domain/word_status.dart';

/// Watches the status for a catalog word in the current account scope.
final class WatchWordStatus {
  WatchWordStatus(this._repository, this._currentSession);

  final WordStatusRepository _repository;
  final CurrentSession _currentSession;

  Stream<WordStatus> execute(CatalogWordRef word) =>
      _repository.watch(word, accountId: _accountScope);

  String get _accountScope =>
      _currentSession.accountIdOrNull ?? guestAccountScope;
}
