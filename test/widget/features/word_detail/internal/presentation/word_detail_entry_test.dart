import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/word_detail/port/presentation_entry.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

const _word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 1);

void main() {
  testWidgets('loading does not mount status capability', (tester) async {
    await _pump(tester, _DeferredReader());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('status-entry')), findsNothing);
  });

  testWidgets('non-empty detail mounts status without quiz when no conjugation',
      (tester) async {
    await _pump(tester, _Reader(Result.success(_result())));
    await tester.pump();

    expect(find.text('hablar'), findsWidgets);
    expect(find.byKey(const Key('status-entry')), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('conjugation enables its tab and quiz callback', (tester) async {
    CatalogWordRef? opened;
    await _pump(
      tester,
      _Reader(Result.success(_result(conjugation: _conjugation))),
      onOpenQuiz: (word, _) => opened = word,
    );
    await tester.pump();

    expect(find.text('Conjugacion'), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    expect(opened, _word);
  });

  testWidgets('empty detail mounts neither status nor quiz', (tester) async {
    await _pump(
      tester,
      _Reader(Result.success(WordDetailResult(
        data: EspJpnWordDetailData(word: _word, entries: const []),
      ))),
    );
    await tester.pump();

    expect(find.text('No data available'), findsOneWidget);
    expect(find.byKey(const Key('status-entry')), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}

Future<void> _pump(
  WidgetTester tester,
  WordDetailQueryPort reader, {
  void Function(CatalogWordRef, String?)? onOpenQuiz,
}) =>
    tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: WordDetailEntry(
          input: const WordDetailPresentationInput(word: _word),
          reader: reader,
          wordStatusRenderer: (_) => const SizedBox(
            key: Key('status-entry'),
          ),
          onOpenQuiz: onOpenQuiz ?? (_, __) {},
        ),
      ),
    ));

WordDetailResult _result({WordDetailConjugation? conjugation}) =>
    WordDetailResult(
      data: EspJpnWordDetailData(
        word: _word,
        entries: [
          WordDetailEspJpnEntry(
            dictionaryId: 1,
            word: 'hablar',
            headword: WordDetailContent.text('hablar'),
            content: WordDetailContent.text('to speak'),
          ),
        ],
        conjugation: conjugation,
      ),
    );

final _conjugation = WordDetailConjugation(
  word: _word,
  conjugations: const {},
  participles: const WordDetailParticiples(
    present: 'hablando',
    past: 'hablado',
  ),
);

final class _Reader implements WordDetailQueryPort {
  const _Reader(this.result);
  final Result<WordDetailResult> result;

  @override
  Future<Result<WordDetailResult>> read(WordDetailQuery query) async => result;
}

final class _DeferredReader implements WordDetailQueryPort {
  final _result = Completer<Result<WordDetailResult>>();

  @override
  Future<Result<WordDetailResult>> read(WordDetailQuery query) =>
      _result.future;
}
