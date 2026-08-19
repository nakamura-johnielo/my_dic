import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/quiz/internal/presentation/search/ui_model/quiz_search_models.dart';
import 'package:my_dic/features/quiz/internal/presentation/search/view_model/quiz_search_view_model.dart';
import 'package:my_dic/features/quiz/port/query/quiz_candidate_reader_port.dart';

final _quizSearchViewModelProvider = StateNotifierProvider.family<
    QuizSearchViewModel, QuizSearchState, _QuizSearchViewModelKey>(
  (_, key) => QuizSearchViewModel(key.reader),
);

/// 注入された 1 つの候補リーダーの状態を作成する。
///
/// キーには意図的にリーダー識別子を使う。これにより、あるエントリで使うフェイクがランタイムリーダー
/// （または別のフェイク）と状態を共有することはない。
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
