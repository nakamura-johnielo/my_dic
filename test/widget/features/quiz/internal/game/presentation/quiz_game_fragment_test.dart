import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/app/bootstrap/session_composition.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/quiz/internal/consts/card_state.dart';
import 'package:my_dic/features/quiz/internal/game/composition/quiz_game_view_model_provider.dart';
import 'package:my_dic/features/quiz/internal/composition/quiz_game_providers.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_load_result.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_query.dart';
import 'package:my_dic/features/quiz/port/presentation_entry.dart';
import 'package:my_dic/features/quiz/internal/game/presentation/view_model/quiz_game_viewmodel.dart';
import 'package:my_dic/features/word_status/presentation/status_button.dart';
import 'package:my_dic/features/word_status/port/presentation_entry.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';

void main() {
  const sessionScope = SessionScopeKey(accountScope: 'test-account', epoch: 1);
  const statusWord = CatalogWordRef(
    catalogId: CatalogId.espJpnMain,
    wordId: 1,
  );
  testWidgets('initializes the quiz when the fragment is entered',
      (tester) async {
    final viewModel = QuizGameViewModel();
    final container = ProviderContainer(overrides: [
      quizGameViewModelProvider.overrideWith((ref) => viewModel),
      sessionScopeKeyProvider.overrideWithValue(sessionScope),
      quizGameLoadProvider(const QuizGameQuery(CatalogWordRef(
        catalogId: CatalogId.espJpnMain,
        wordId: 1,
      ))).overrideWith((ref) async => const QuizGameLoadResult.noConjugation()),
      dictionaryStatusButtonsViewModelProvider(
        const WordStatusEntryKey(scope: sessionScope, word: statusWord),
      ).overrideWith((ref) => const _NoopWordStatusViewModel()),
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
