import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/word_status/application/port/word_status_repository.dart';
import 'package:my_dic/features/word_status/domain/word_status.dart';

/// Reads the status for a catalog word in the current account scope.
final class FetchWordStatus {
  FetchWordStatus(this._repository, this._currentSession);

  final WordStatusRepository _repository;
  final CurrentSession _currentSession;

  Future<Result<WordStatus>> execute(CatalogWordRef word) async {
    final result = await _repository.get(word, accountId: _accountScope);
    return result.map(
      (status) =>
          status ??
          WordStatus(
            word: word,
            isLearned: false,
            isBookmarked: false,
            hasNote: false,
            updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          ),
    );
  }

  String get _accountScope =>
      _currentSession.accountIdOrNull ?? guestAccountScope;
}
