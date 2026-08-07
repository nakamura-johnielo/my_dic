import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/application/update_status_usecase.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart';
import 'package:my_dic/features/jpn_esp_word_status/application/update_jpn_esp_status_usecase.dart';
import 'package:my_dic/features/word_status/presentation/status_button.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';

sealed class WordStatusCommandEvent {
  const WordStatusCommandEvent();
}

class ToggleLearnedSucceeded extends WordStatusCommandEvent {
  const ToggleLearnedSucceeded();
}

class ToggleLearnedFailed extends WordStatusCommandEvent {
  const ToggleLearnedFailed();
}

class ToggleBookmarkedSucceeded extends WordStatusCommandEvent {
  const ToggleBookmarkedSucceeded();
}

class ToggleBookmarkedFailed extends WordStatusCommandEvent {
  const ToggleBookmarkedFailed();
}

class ToggleNoteSucceeded extends WordStatusCommandEvent {
  const ToggleNoteSucceeded();
}

class ToggleNoteFailed extends WordStatusCommandEvent {
  const ToggleNoteFailed();
}

class WordStatusState {
  const WordStatusState({
    required this.status,
  });
  final QueryState<WordStatus> status;
  bool get isLearned => status.dataOrNull?.isLearned ?? false;
  bool get isBookmarked => status.dataOrNull?.isBookmarked ?? false;
  bool get hasNote => status.dataOrNull?.hasNote ?? false;
  factory WordStatusState.fromAsync(AsyncValue<WordStatus> value) => value.when(
        data: (status) => WordStatusState(status: QueryState.data(status)),
        loading: () => WordStatusState(
          status: QueryState.loading(previousData: value.valueOrNull),
        ),
        error: (error, _) => WordStatusState(
          status: QueryState.failure(_asAppError(error),
              previousData: value.valueOrNull),
        ),
      );
}

class JpnEspWordStatusState {
  const JpnEspWordStatusState({
    required this.status,
  });
  final QueryState<JpnEspWordStatus> status;
  bool get isLearned => status.dataOrNull?.isLearned ?? false;
  bool get isBookmarked => status.dataOrNull?.isBookmarked ?? false;
  bool get hasNote => status.dataOrNull?.hasNote ?? false;
  factory JpnEspWordStatusState.fromAsync(AsyncValue<JpnEspWordStatus> value) =>
      value.when(
        data: (status) =>
            JpnEspWordStatusState(status: QueryState.data(status)),
        loading: () => JpnEspWordStatusState(
          status: QueryState.loading(previousData: value.valueOrNull),
        ),
        error: (error, _) => JpnEspWordStatusState(
          status: QueryState.failure(_asAppError(error),
              previousData: value.valueOrNull),
        ),
      );
}

AppError _asAppError(Object error) => error is AppError
    ? error
    : UnexpectedError(
        message: 'Unable to load word status.', originalError: error);

class EspJpnWordStatusCommand extends StateNotifier<WordStatusCommandEvent?> {
  EspJpnWordStatusCommand(this._wordId, this._useCase) : super(null);
  final int _wordId;
  final IUpdateStatusUseCase _useCase;
  Future<void> toggleBookmark(bool current) => _update(
        UpdateStatusInputData(
          wordId: _wordId,
          isBookmarked: FieldUpdate.set(!current),
        ),
        const ToggleBookmarkedSucceeded(),
        const ToggleBookmarkedFailed(),
      );
  Future<void> toggleLearned(bool current) => _update(
        UpdateStatusInputData(
          wordId: _wordId,
          isLearned: FieldUpdate.set(!current),
        ),
        const ToggleLearnedSucceeded(),
        const ToggleLearnedFailed(),
      );
  Future<void> toggleHasNote(bool current) => _update(
        UpdateStatusInputData(
          wordId: _wordId,
          hasNote: FieldUpdate.set(!current),
        ),
        const ToggleNoteSucceeded(),
        const ToggleNoteFailed(),
      );
  Future<void> _update(UpdateStatusInputData input,
      WordStatusCommandEvent success, WordStatusCommandEvent failure) async {
    final result = await _useCase.execute(input);
    if (!mounted) return;
    result.when(
        failure: (_) => state = failure, success: (_) => state = success);
  }
}

class JpnEspWordStatusCommand extends StateNotifier<WordStatusCommandEvent?> {
  JpnEspWordStatusCommand(this._wordId, this._useCase) : super(null);
  final int _wordId;
  final IUpdateJpnEspStatusUseCase _useCase;
  Future<void> toggleBookmark(bool current) => _update(
        UpdateJpnEspStatusInputData(
          wordId: _wordId,
          isBookmarked: FieldUpdate.set(!current),
        ),
        const ToggleBookmarkedSucceeded(),
        const ToggleBookmarkedFailed(),
      );
  Future<void> toggleLearned(bool current) => _update(
        UpdateJpnEspStatusInputData(
          wordId: _wordId,
          isLearned: FieldUpdate.set(!current),
        ),
        const ToggleLearnedSucceeded(),
        const ToggleLearnedFailed(),
      );
  Future<void> toggleHasNote(bool current) => _update(
        UpdateJpnEspStatusInputData(
          wordId: _wordId,
          hasNote: FieldUpdate.set(!current),
        ),
        const ToggleNoteSucceeded(),
        const ToggleNoteFailed(),
      );
  Future<void> _update(UpdateJpnEspStatusInputData input,
      WordStatusCommandEvent success, WordStatusCommandEvent failure) async {
    final result = await _useCase.execute(input);
    if (!mounted) return;
    result.when(
        failure: (_) => state = failure, success: (_) => state = success);
  }
}

class EspJpnWordStatusViewModel implements WordStatusViewModel {
  const EspJpnWordStatusViewModel(this._state, this._command);
  final WordStatusState _state;
  final EspJpnWordStatusCommand _command;
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

class JpnEspWordStatusViewModel implements WordStatusViewModel {
  const JpnEspWordStatusViewModel(this._state, this._command);
  final JpnEspWordStatusState _state;
  final JpnEspWordStatusCommand _command;
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
