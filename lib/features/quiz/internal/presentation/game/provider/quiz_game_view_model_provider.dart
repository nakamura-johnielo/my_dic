import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/port/error/quiz_game_load_error.dart';
import 'package:my_dic/features/quiz/port/query/quiz_game_query.dart';
import 'package:my_dic/features/quiz/port/query/quiz_game_reader_port.dart';
import 'package:my_dic/features/quiz/port/result/quiz_game_load_outcome.dart';
import 'package:my_dic/features/quiz/internal/presentation/game/ui_model/quiz_game_state.dart';
import 'package:my_dic/features/quiz/internal/presentation/game/view_model/quiz_game_viewmodel.dart';

final quizGameViewModelProvider =
    StateNotifierProvider<QuizGameViewModel, QuizGameState>(
        (ref) => QuizGameViewModel());

final _quizGameLoadProvider =
    FutureProvider.autoDispose.family<QuizGameLoadOutcome, _QuizGameLoadKey>(
  (_, key) => key.reader.load(key.query).then(
        (result) => result.when(
          success: (outcome) => outcome,
          failure: (error) => QuizGameLoadOutcome.failure(QuizGameLoadError(
              source: QuizGameLoadSource.primaryCatalog,
              message: error.message)),
        ),
      ),
);

/// Loads one game with an explicitly injected reader.
///
/// Reader identity is part of the family key, preventing state sharing across
/// runtime and fake capability instances.
AutoDisposeFutureProvider<QuizGameLoadOutcome> quizGameLoadProvider(
  QuizGameQueryPort reader,
  QuizGameQuery query,
) =>
    _quizGameLoadProvider(_QuizGameLoadKey(reader: reader, query: query));

final class _QuizGameLoadKey {
  const _QuizGameLoadKey({required this.reader, required this.query});

  final QuizGameQueryPort reader;
  final QuizGameQuery query;

  @override
  bool operator ==(Object other) =>
      other is _QuizGameLoadKey &&
      identical(other.reader, reader) &&
      other.query == query;

  @override
  int get hashCode => Object.hash(identityHashCode(reader), query);
}
