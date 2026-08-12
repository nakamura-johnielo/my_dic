import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/internal/composition/quiz_game_providers.dart';
import 'package:my_dic/features/quiz/port/game_loader.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_load_result.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_query.dart';
import 'package:my_dic/features/quiz/port/presentation_entry.dart';
import 'package:my_dic/features/quiz/port/presentation_input.dart';

const _word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);

void main() {
  testWidgets('Gate B: a disposed game route ignores late aggregate completion',
      (tester) async {
    final loader = _DeferredLoader();
    final container = ProviderContainer(overrides: [
      loadQuizGameProvider.overrideWithValue(loader),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: QuizGameFragment(
          input: const QuizGamePresentationInput(word: _word),
          onOpenWordDetail: (_) {},
        ),
      ),
    ));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    loader.completer.complete(const QuizGameLoadResult.noConjugation());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

final class _DeferredLoader implements LoadQuizGame {
  final completer = Completer<QuizGameLoadResult>();
  @override
  Future<QuizGameLoadResult> load(QuizGameQuery query) => completer.future;
}
