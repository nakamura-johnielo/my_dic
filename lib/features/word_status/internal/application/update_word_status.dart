import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/word_status/port/commands.dart';
import 'package:my_dic/features/word_status/port/repository.dart';

final class UpdateWordStatusInteractor {
  UpdateWordStatusInteractor(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final IWordStatusRepository _repository;
  final DateTime Function() _clock;

  Future<Result<void>> execute(
    UpdateWordStatusCommand command, {
    required String? accountId,
  }) async {
    if (!command.hasChanges) return const Result.success(null);
    final result = await _repository.update(
      command.word,
      isLearned: command.isLearned,
      isBookmarked: command.isBookmarked,
      hasNote: command.hasNote,
      updatedAt: _clock().toUtc(),
      accountId: accountId,
    );
    return result.map((_) {});
  }
}
