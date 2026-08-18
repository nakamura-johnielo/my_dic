import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/quiz/internal/presentation/search/ui_model/quiz_search_models.dart';
import 'package:my_dic/features/quiz/internal/presentation/search/view_model/quiz_search_view_model.dart';
import 'package:my_dic/features/quiz/port/query/quiz_candidate_reader_port.dart';

final _quizSearchViewModelProvider = StateNotifierProvider.family<
    QuizSearchViewModel, QuizSearchState, _QuizSearchViewModelKey>(
  (_, key) => QuizSearchViewModel(key.reader),
);

/// Creates state for one injected candidate reader.
///
/// The key intentionally uses reader identity so a fake used by one entry can
/// never share state with the runtime reader (or another fake).
StateNotifierProvider<QuizSearchViewModel, QuizSearchState>
    quizSearchViewModelProvider(QuizCandidateQueryPort reader) =>
        _quizSearchViewModelProvider(_QuizSearchViewModelKey(reader));

final class _QuizSearchViewModelKey {
  const _QuizSearchViewModelKey(this.reader);

  final QuizCandidateQueryPort reader;

  @override
  bool operator ==(Object other) =>
      other is _QuizSearchViewModelKey && identical(other.reader, reader);

  @override
  int get hashCode => identityHashCode(reader);
}
