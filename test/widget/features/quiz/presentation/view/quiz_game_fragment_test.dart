import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/conjugation_reader.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/quiz/application/fetch_english_conj/i_fetch_english_conj_usecase.dart';
import 'package:my_dic/features/quiz/consts/card_state.dart';
import 'package:my_dic/features/quiz/di/provider_di.dart';
import 'package:my_dic/features/quiz/di/view_model_di.dart';
import 'package:my_dic/features/quiz/presentation/view/quiz_game_fragment.dart';
import 'package:my_dic/features/quiz/presentation/view_model/quiz_game_viewmodel.dart';
import 'package:my_dic/features/word_status/presentation/status_button.dart';
import 'package:my_dic/features/word_status/presentation/word_status_providers.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';

class _FakeConjugationReader implements ConjugationReader {
  @override
  Future<Result<CatalogConjugation?>> getConjugation(
    CatalogWordRef word,
  ) async =>
      const Result.success(null);

  @override
  Future<Result<bool>> hasConjugation(CatalogWordRef word) async =>
      const Result.success(false);
}

class _FakeFetchEnglishConjUseCase implements IFetchEnglishConjUseCase {
  @override
  Future<Result<Map<String, String>>> execute(int wordId) async =>
      const Result.success({});
}

void main() {
  testWidgets('initializes the quiz when the fragment is entered',
      (tester) async {
    final viewModel = QuizGameViewModel(
      _FakeConjugationReader(),
      _FakeFetchEnglishConjUseCase(),
    );
    final container = ProviderContainer(overrides: [
      quizGameViewModelProvider.overrideWith((ref) => viewModel),
      conjEnglishProvider.overrideWith((ref) async => const {}),
      beConjProvider.overrideWith((ref) async => const {}),
      englishConjByWordIdProvider(1).overrideWith((ref) async => const {}),
      quizConjugacionsProvider(1).overrideWith((ref) async => null),
      dictionaryStatusButtonsViewModelProvider(const CatalogWordRef(
        catalogId: CatalogId.espJpnMain,
        wordId: 1,
      )).overrideWith((ref) => const _NoopWordStatusViewModel()),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: QuizGameFragment(
            route: QuizGameRoute(wordId: 1, word: 'hablar'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(viewModel.state.currentIndex, 0);
    expect(viewModel.state.hasCurrentQuestion, isTrue);
    expect(viewModel.state.quizCardState, QuizCardState.question);
  });
}

class _NoopWordStatusViewModel implements WordStatusViewModel {
  const _NoopWordStatusViewModel();

  @override
  bool get hasNote => false;
  @override
  bool get isBookmarked => false;
  @override
  bool get isLearned => false;
  @override
  bool get isLoading => false;
  @override
  String? get readError => null;
  @override
  Future<void> toggleBookmark() async {}
  @override
  Future<void> toggleHasNote() async {}
  @override
  Future<void> toggleLearned() async {}
}
