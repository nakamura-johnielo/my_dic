import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/port/error/quiz_game_load_error.dart';
import 'package:my_dic/features/quiz/port/presentation_dependencies.dart';
import 'package:my_dic/features/quiz/port/query/quiz_game_query.dart';
import 'package:my_dic/features/quiz/port/result/quiz_game_load_outcome.dart';
import 'package:my_dic/features/quiz/internal/game/presentation/ui_model/quiz_game_state.dart';
import 'package:my_dic/features/quiz/internal/game/presentation/view_model/quiz_game_viewmodel.dart';

final quizGameViewModelProvider =
    StateNotifierProvider<QuizGameViewModel, QuizGameState>(
        (ref) => QuizGameViewModel());

final quizGameLoadProvider =
    FutureProvider.autoDispose.family<QuizGameLoadOutcome, QuizGameQuery>(
  (ref, query) => ref.read(quizGameReaderDependencyProvider).load(query).then(
        (result) => result.when(
          success: (outcome) => outcome,
          failure: (error) => QuizGameLoadOutcome.failure(QuizGameLoadError(
              source: QuizGameLoadSource.primaryCatalog,
              message: error.message)),
        ),
      ),
);
