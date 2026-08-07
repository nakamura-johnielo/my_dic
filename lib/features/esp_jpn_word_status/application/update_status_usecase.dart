import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';

class UpdateStatusInputData {
  const UpdateStatusInputData({
    required this.wordId,
    this.isLearned = const FieldUpdate.unchanged(),
    this.isBookmarked = const FieldUpdate.unchanged(),
    this.hasNote = const FieldUpdate.unchanged(),
  });

  final int wordId;
  final FieldUpdate<bool> isLearned;
  final FieldUpdate<bool> isBookmarked;
  final FieldUpdate<bool> hasNote;

  bool get hasChanges =>
      isLearned.isChanged || isBookmarked.isChanged || hasNote.isChanged;
}

abstract interface class IUpdateStatusUseCase {
  Future<Result<void>> execute(UpdateStatusInputData input);
}

class UpdateStatusInteractor implements IUpdateStatusUseCase {
  UpdateStatusInteractor(this._repository, this._currentSession);

  final IWordStatusRepository _repository;
  final CurrentSession _currentSession;

  @override
  Future<Result<void>> execute(UpdateStatusInputData input) async {
    if (!input.hasChanges) return const Result.success(null);

    final result = await _repository.updateLocalWordStatus(
      wordId: input.wordId,
      isLearned: input.isLearned,
      isBookmarked: input.isBookmarked,
      hasNote: input.hasNote,
      editAt: DateTime.now().toUtc(),
      accountId: _currentSession.accountIdOrNull,
    );
    if (result.isFailure) return Result.failure(result.errorOrNull!);
    return const Result.success(null);
  }
}
