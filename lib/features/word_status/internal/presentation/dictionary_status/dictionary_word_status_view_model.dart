import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/features/word_status/internal/presentation/dictionary_status/dictionary_word_status_command.dart';
import 'package:my_dic/features/word_status/internal/presentation/dictionary_status/status_button.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

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

final class DictionaryWordStatusViewModel
    implements WordStatusViewModel, WordStatusCommandProgress {
  const DictionaryWordStatusViewModel(this._state, this._command);
  final WordStatusState _state;
  final DictionaryWordStatusCommand _command;
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
        _ => null
      };
  @override
  Future<void> toggleLearned() => _command.toggleLearned(isLearned);
  @override
  Future<void> toggleBookmark() => _command.toggleBookmark(isBookmarked);
  @override
  Future<void> toggleHasNote() => _command.toggleHasNote(hasNote);
  @override
  bool get isSubmitting => _command.isSubmitting;
}

AppError asWordStatusReadError(Object error) => error is AppError
    ? error
    : UnexpectedError(
        message: 'Unable to load word status.', originalError: error);
