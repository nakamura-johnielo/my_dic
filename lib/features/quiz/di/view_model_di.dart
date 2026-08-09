import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/catalog_composition.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/quiz/application/conjugation/quiz_conjugation.dart';
import 'package:my_dic/features/quiz/di/usecase_di.dart';
import 'package:my_dic/features/quiz/presentation/ui_model/quiz_game_model.dart';
import 'package:my_dic/features/quiz/presentation/ui_model/quiz_search_model.dart';
import 'package:my_dic/features/quiz/presentation/view_model/quiz_game_viewmodel.dart';
import 'package:my_dic/features/quiz/presentation/view_model/quiz_search_view_model.dart';

final quizConjugacionsProvider =
    FutureProvider.autoDispose.family<QuizConjugation?, int>(
  (ref, wordId) async {
    final controller = ref.read(quizGameViewModelProvider.notifier);
    return controller.getConjugaciones(CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: wordId,
    ));
  },
);

final quizSearchViewModelProvider =
    StateNotifierProvider<QuizSearchViewModel, QuizSearchState>((ref) {
  return QuizSearchViewModel(ref.read(quizCandidateSourceProvider));
});

final quizGameViewModelProvider =
    StateNotifierProvider<QuizGameViewModel, QuizGameState>((ref) {
  final conjugationReader = ref.read(conjugationReaderProvider);
  final fetchEnglishConjInteractor = ref.read(fetchEnglishConjUseCaseProvider);
  return QuizGameViewModel(conjugationReader, fetchEnglishConjInteractor);
});
