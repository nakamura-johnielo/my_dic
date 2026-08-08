import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/catalog_composition.dart';
import 'package:my_dic/core/di/usecase/usecase_di.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/features/quiz/di/usecase_di.dart';
import 'package:my_dic/features/quiz/presentation/ui_model/quiz_game_model.dart';
import 'package:my_dic/features/quiz/presentation/ui_model/quiz_search_model.dart';
import 'package:my_dic/features/quiz/presentation/view_model/quiz_game_viewmodel.dart';
import 'package:my_dic/features/quiz/presentation/view_model/quiz_search_view_model.dart';

final quizConjugacionsProvider =
    FutureProvider.autoDispose.family<EspConjugacions?, int>(
  (ref, wordId) async {
    final controller = ref.read(quizGameViewModelProvider.notifier);
    return await controller.getConjugaciones(wordId);
  },
);

final quizSearchViewModelProvider =
    StateNotifierProvider<QuizSearchViewModel, QuizSearchState>((ref) {
  return QuizSearchViewModel(ref.read(quizCandidateSourceProvider));
});

final quizGameViewModelProvider =
    StateNotifierProvider<QuizGameViewModel, QuizGameState>((ref) {
  final fetchConjugationInteractor =
      ref.read(fetchEspConjugationUseCaseProvider);
  final fetchEnglishConjInteractor = ref.read(fetchEnglishConjUseCaseProvider);
  return QuizGameViewModel(
      fetchConjugationInteractor, fetchEnglishConjInteractor);
});
