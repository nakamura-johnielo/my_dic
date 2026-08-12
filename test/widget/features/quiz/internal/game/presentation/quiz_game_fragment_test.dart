import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/internal/composition/quiz_game_providers.dart';
import 'package:my_dic/features/quiz/internal/game/presentation/view/quiz_game_fragment.dart';
import 'package:my_dic/features/quiz/port/game_loader.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_load_result.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_load_source.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_query.dart';
import 'package:my_dic/features/quiz/port/presentation_input.dart';

const _word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 1);

void main() {
  testWidgets('renders no-data variant for a valid word without conjugation',
      (tester) async {
    final container = ProviderContainer(overrides: [
      loadQuizGameProvider.overrideWithValue(_Loader([
        const QuizGameLoadResult.noConjugation(),
      ])),
    ]);
    addTearDown(container.dispose);

    await _pump(tester, container);

    expect(find.text('No results....'), findsOneWidget);
  });

  testWidgets('retries a typed source failure at most once per double tap',
      (tester) async {
    final loader = _Loader([
      const QuizGameLoadResult.failure(
        source: QuizGameLoadSource.englishGuide,
        error: 'asset unavailable',
      ),
      const QuizGameLoadResult.noConjugation(),
    ]);
    final container = ProviderContainer(overrides: [
      loadQuizGameProvider.overrideWithValue(loader),
    ]);
    addTearDown(container.dispose);

    await _pump(tester, container);
    expect(find.byKey(const Key('quiz-game-retry')), findsOneWidget);

    await tester.tap(find.byKey(const Key('quiz-game-retry')));
    await tester.tap(find.byKey(const Key('quiz-game-retry')));
    await tester.pumpAndSettle();

    expect(loader.calls, 2);
    expect(find.text('No results....'), findsOneWidget);
  });
}

Future<void> _pump(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: QuizGameFragment(
        input: const QuizGamePresentationInput(
          word: _word,
          displayHint: 'hablar',
        ),
        onOpenWordDetail: (_) {},
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

final class _Loader implements LoadQuizGame {
  _Loader(this._results);

  final List<QuizGameLoadResult> _results;
  int calls = 0;

  @override
  Future<QuizGameLoadResult> load(QuizGameQuery query) async {
    final index = calls++;
    return _results[index];
  }
}
