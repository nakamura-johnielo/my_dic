import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/word_status/internal/application/update_word_status.dart';
import 'package:my_dic/features/word_status/port/commands.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';
import 'package:my_dic/features/word_status/status_button.dart';

/// UI state for a status belonging to a catalog word.
///
/// [fromAsync] deliberately retains the prior value for loading and read
/// failures so a status control does not flicker back to its default state.
final class WordStatusState {
  const WordStatusState({required this.status});

  final QueryState<WordStatus> status;

  bool get isLearned => status.dataOrNull?.isLearned ?? false;
  bool get isBookmarked => status.dataOrNull?.isBookmarked ?? false;
  bool get hasNote => status.dataOrNull?.hasNote ?? false;

  factory WordStatusState.fromAsync(AsyncValue<WordStatus> value) => value.when(
        skipLoadingOnRefresh: false,
        skipError: false,
        data: (status) => WordStatusState(status: QueryState.data(status)),
        loading: () => WordStatusState(
          status: QueryState.loading(previousData: value.valueOrNull),
        ),
        error: (error, _) => WordStatusState(
          status: QueryState.failure(
            asWordStatusReadError(error),
            previousData: value.valueOrNull,
          ),
        ),
      );
}

/// Events exposed to the UI after a status toggle finishes.
sealed class WordStatusCommandEvent {
  const WordStatusCommandEvent();
}

final class ToggleLearnedSucceeded extends WordStatusCommandEvent {
  const ToggleLearnedSucceeded();
}

final class ToggleLearnedFailed extends WordStatusCommandEvent {
  const ToggleLearnedFailed();
}

final class ToggleBookmarkedSucceeded extends WordStatusCommandEvent {
  const ToggleBookmarkedSucceeded();
}

final class ToggleBookmarkedFailed extends WordStatusCommandEvent {
  const ToggleBookmarkedFailed();
}

final class ToggleNoteSucceeded extends WordStatusCommandEvent {
  const ToggleNoteSucceeded();
}

final class ToggleNoteFailed extends WordStatusCommandEvent {
  const ToggleNoteFailed();
}

/// Executes mutations for one [CatalogWordRef].
final class WordStatusCommand extends StateNotifier<WordStatusCommandEvent?> {
  WordStatusCommand(this._word, this._useCase, {required this.accountId})
      : super(null);

  final CatalogWordRef _word;
  final UpdateWordStatus _useCase;
  final String? accountId;

  Future<void> toggleBookmark(bool current) => _update(
        isBookmarked: FieldUpdate.set(!current),
        success: const ToggleBookmarkedSucceeded(),
        failure: const ToggleBookmarkedFailed(),
      );

  Future<void> toggleLearned(bool current) => _update(
        isLearned: FieldUpdate.set(!current),
        success: const ToggleLearnedSucceeded(),
        failure: const ToggleLearnedFailed(),
      );

  Future<void> toggleHasNote(bool current) => _update(
        hasNote: FieldUpdate.set(!current),
        success: const ToggleNoteSucceeded(),
        failure: const ToggleNoteFailed(),
      );

  Future<void> _update({
    FieldUpdate<bool> isLearned = const FieldUpdate.unchanged(),
    FieldUpdate<bool> isBookmarked = const FieldUpdate.unchanged(),
    FieldUpdate<bool> hasNote = const FieldUpdate.unchanged(),
    required WordStatusCommandEvent success,
    required WordStatusCommandEvent failure,
  }) async {
    final result = await _useCase.execute(
      UpdateWordStatusCommand(
        word: _word,
        isLearned: isLearned,
        isBookmarked: isBookmarked,
        hasNote: hasNote,
      ),
      accountId: accountId,
    );
    if (!mounted) return;
    state = result.isSuccess ? success : failure;
  }
}

/// Adapter from unified dictionary status state to the reusable button UI.
final class DictionaryWordStatusViewModel implements WordStatusViewModel {
  const DictionaryWordStatusViewModel(this._state, this._command);

  final WordStatusState _state;
  final WordStatusCommand _command;

  @override
  bool get isLearned => _state.isLearned;
  @override
  bool get isBookmarked => _state.isBookmarked;
  @override
  bool get hasNote => _state.hasNote;
  @override
  bool get isLoading => _state.status.isInitialLoading;
  @override
  String? get readError => switch (_state.status) {
        QueryFailure(error: final error) => AppErrorMessage.from(error).text,
        _ => null,
      };

  @override
  Future<void> toggleLearned() => _command.toggleLearned(isLearned);
  @override
  Future<void> toggleBookmark() => _command.toggleBookmark(isBookmarked);
  @override
  Future<void> toggleHasNote() => _command.toggleHasNote(hasNote);
}

AppError asWordStatusReadError(Object error) => error is AppError
    ? error
    : UnexpectedError(
        message: 'Unable to load word status.',
        originalError: error,
      );
