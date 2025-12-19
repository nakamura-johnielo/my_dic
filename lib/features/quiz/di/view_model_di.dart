import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Constants/Enums/cardState.dart';
import 'package:my_dic/_Interface_Adapter/Controller/quiz_controller.dart';
import 'package:my_dic/core/di/data/repository_di.dart';
import 'package:my_dic/core/di/usecase/usecase_di.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/conjugacions.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/quiz_searched_item.dart';
import 'package:my_dic/core/domain/usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/features/quiz/di/usecase_di.dart';
import 'package:my_dic/features/quiz/domain/usecase/fetch_english_conj.dart/i_fetch_english_conj_usecase.dart';
import 'package:my_dic/features/quiz/presentation/ui_model/new_quiz_model.dart';
import 'package:my_dic/features/quiz/presentation/ui_model/quiz_ui_model.dart';
import 'package:my_dic/features/quiz/presentation/view_model/new_quiz_viewmodel.dart';
import 'package:my_dic/features/quiz/presentation/view_model/quiz_view_model.dart';
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
    FutureProvider.autoDispose.family<Conjugacions?, int>(
  (ref, wordId) async {
    final controller = ref.read(quizGameViewModelProvider.notifier);
    return await controller.getConjugaciones(wordId);
  },
);

final quizWordProvider = StateProvider<String>((ref) => "");

// QuizStateをRiverpodで管理するProvider
final quizStateProvider = StateNotifierProvider<QuizStateNotifier, QuizState2>(
  (ref) => QuizStateNotifier(),
);

final quizSearchViewModelProvider =
    StateNotifierProvider<QuizSearchViewModel, QuizSearchState>((ref) {
  // final searchUsecase=
  return QuizSearchViewModel(ref.read(searchWordUseCaseProvider));
});

final quizGameViewModelProvider =
    StateNotifierProvider<QuizViewModel, QuizState>((ref) {
  // final searchUsecase=
  final fetchConjugationInteractor = ref.read(fetchConjugationUseCaseProvider);
  final fetchEnglishConjInteractor = ref.read(fetchEnglishConjUseCaseProvider);
  return QuizViewModel(fetchConjugationInteractor, fetchEnglishConjInteractor);
});
