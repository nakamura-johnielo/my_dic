import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/port/presentation_dependencies.dart';
import 'package:my_dic/features/quiz/port/query/quiz_game_query.dart';
import 'package:my_dic/features/quiz/port/reader/quiz_game_reader_port.dart';
import 'package:my_dic/features/quiz/port/result/quiz_game_load_outcome.dart';
import 'package:my_dic/features/quiz/port/presentation_entry.dart';
import 'package:my_dic/features/quiz/port/presentation_input.dart';

const _word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);

void main() {
  testWidgets('Gate B: a disposed game route ignores late aggregate completion',
      (tester) async {
    final loader = _DeferredLoader();
    final container = ProviderContainer(overrides: [
      quizGameReaderDependencyProvider.overrideWithValue(loader),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: QuizGameFragment(
          input: const QuizGamePresentationInput(word: _word),
          onOpenWordDetail: (_) {},
          wordStatusRenderer: (_) => const SizedBox.shrink(),
        ),
      ),
    ));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    loader.completer
        .complete(Result.success(const QuizGameLoadOutcome.noConjugation()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

final class _DeferredLoader implements QuizGameQueryPort {
  final completer = Completer<Result<QuizGameLoadOutcome>>();
  @override
  Future<Result<QuizGameLoadOutcome>> load(QuizGameQuery query) =>
      completer.future;
}
