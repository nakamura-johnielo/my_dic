import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/word_status/application/model/update_word_status_command.dart';
import 'package:my_dic/features/word_status/application/port/word_status_repository.dart';

/// Applies a partial status update in the current session's account context.
final class UpdateWordStatus {
  UpdateWordStatus(
    this._repository,
    this._currentSession, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final WordStatusRepository _repository;
  final CurrentSession _currentSession;
  final DateTime Function() _clock;

  Future<Result<void>> execute(UpdateWordStatusCommand command) async {
    if (!command.hasChanges) return const Result.success(null);

    final result = await _repository.update(
      command.word,
      isLearned: command.isLearned,
      isBookmarked: command.isBookmarked,
      hasNote: command.hasNote,
      updatedAt: _clock().toUtc(),
      accountId: _currentSession.accountIdOrNull,
    );
    return result.map((_) {});
  }
}
