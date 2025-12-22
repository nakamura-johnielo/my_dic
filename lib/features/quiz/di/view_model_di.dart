import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/quiz/consts/card_state.dart';
import 'package:my_dic/core/di/usecase/usecase_di.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/features/quiz/di/usecase_di.dart';
import 'package:my_dic/features/quiz/presentation/ui_model/quiz_game_model.dart';
import 'package:my_dic/features/quiz/presentation/ui_model/quiz_search_model.dart';
import 'package:my_dic/features/quiz/presentation/view_model/quiz_game_viewmodel.dart';
import 'package:my_dic/features/quiz/presentation/view_model/quiz_search_view_model.dart';
import 'package:my_dic/features/search/di/usecase_di.dart';

/// クイズ検索結果リストのプロバイダー
// final quizSearchedItemsProvider =
//     StateProvider<List<QuizSearchedItem>>((ref) => []);

// /// クイズで選択中の単語IDのプロバイダー
// final quizSelectedWordIdProvider = StateProvider<int?>((ref) => null);

// final quizWordDataProvider = StateProvider<Conjugacions?>((ref) => null);

// final quizSearchQueryProvider = StateProvider<String>((ref) => '');

final quizCardStateProvider =
    StateProvider<QuizCardState>((ref) => QuizCardState.question);

// final quizControllerProvider = Provider<QuizController>((ref) {
//   return QuizController(ref.read(esEnConjugacionRepositoryProvider),
//       ref.read(fetchConjugationUseCaseProvider));
// });

final quizConjugacionsProvider =
    FutureProvider.autoDispose.family<EspConjugacions?, int>(
  (ref, wordId) async {
    final controller = ref.read(quizGameViewModelProvider.notifier);
    return await controller.getConjugaciones(wordId);
  },
);

final quizWordProvider = StateProvider<String>((ref) => "");

// QuizStateをRiverpodで管理するProvider
// final quizStateProvider = StateNotifierProvider<QuizStateNotifier, QuizState2>(
//   (ref) => QuizStateNotifier(),
// );

final quizSearchViewModelProvider =
    StateNotifierProvider<QuizSearchViewModel, QuizSearchState>((ref) {
  // final searchUsecase=
  return QuizSearchViewModel(ref.read(searchWordUseCaseProvider));
});

final quizGameViewModelProvider =
    StateNotifierProvider<QuizGameViewModel, QuizGameState>((ref) {
  // final searchUsecase=
  final fetchConjugationInteractor = ref.read(fetchEspConjugationUseCaseProvider);
  final fetchEnglishConjInteractor = ref.read(fetchEnglishConjUseCaseProvider);
  return QuizGameViewModel(fetchConjugationInteractor, fetchEnglishConjInteractor);
});
