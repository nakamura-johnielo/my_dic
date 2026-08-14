import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/word_detail/port/presentation_entry.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

const _word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);

void main() {
  testWidgets(
      'Gate B: primary data survives conjugation failure without quiz UI',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: WordDetailEntry(
          input: const WordDetailPresentationInput(word: _word),
          reader: const _Reader(),
          wordStatusRenderer: (_) => const SizedBox(
            key: Key('status-entry'),
          ),
          onOpenQuiz: (_, __) {},
        ),
      ),
    ));
    await tester.pump();

    expect(find.text('hablar'), findsWidgets);
    expect(find.byKey(const Key('status-entry')), findsOneWidget);
    expect(find.text('Conjugacion'), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}

final class _Reader implements WordDetailQueryPort {
  const _Reader();

  @override
  Future<Result<WordDetailResult>> read(WordDetailQuery query) async =>
      Result.success(WordDetailResult(
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
        ),
        issues: const [
          WordDetailConjugationIssue(
            error: WordDetailDataUnavailableError(
              message: 'conjugation unavailable',
            ),
          ),
        ],
      ));
}
