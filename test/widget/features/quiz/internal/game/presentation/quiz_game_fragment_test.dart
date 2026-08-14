import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/port/error/quiz_game_load_error.dart';
import 'package:my_dic/features/quiz/port/presentation_dependencies.dart';
import 'package:my_dic/features/quiz/internal/game/presentation/view/quiz_game_fragment.dart';
import 'package:my_dic/features/quiz/port/presentation_input.dart';
import 'package:my_dic/features/quiz/port/query/quiz_game_query.dart';
import 'package:my_dic/features/quiz/port/reader/quiz_game_reader_port.dart';
import 'package:my_dic/features/quiz/port/result/quiz_game_load_outcome.dart';

const _word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 1);

void main() {
  testWidgets('renders no-data variant for a valid word without conjugation',
      (tester) async {
    final container = ProviderContainer(overrides: [
      quizGameReaderDependencyProvider.overrideWithValue(_Loader([
        const QuizGameLoadOutcome.noConjugation(),
      ])),
    ]);
    addTearDown(container.dispose);

    await _pump(tester, container);

    expect(find.text('No results....'), findsOneWidget);
  });

  testWidgets('retries a typed source failure at most once per double tap',
      (tester) async {
    final loader = _Loader([
      const QuizGameLoadOutcome.failure(QuizGameLoadError(
          source: QuizGameLoadSource.englishGuide,
          message: 'asset unavailable')),
      const QuizGameLoadOutcome.noConjugation(),
    ]);
    final container = ProviderContainer(overrides: [
      quizGameReaderDependencyProvider.overrideWithValue(loader),
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
        wordStatusRenderer: (_) => const SizedBox.shrink(),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

final class _Loader implements QuizGameQueryPort {
  _Loader(this._results);

  final List<QuizGameLoadOutcome> _results;
  int calls = 0;

  @override
  Future<Result<QuizGameLoadOutcome>> load(QuizGameQuery query) async {
    final index = calls++;
    return Result.success(_results[index]);
  }
}
