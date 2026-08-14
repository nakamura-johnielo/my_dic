import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/search/port/presentation_entry.dart';
import 'package:my_dic/features/search/port/search.dart';

void main() {
  testWidgets('query change removes old results while the new page loads',
      (tester) async {
    final reader = _QueryPort();
    await tester.pumpWidget(_app(reader));

    await tester.enterText(find.byType(TextField), 'hablar');
    await tester.pump();
    reader.completeNext(_page('hablar'));
    await tester.pumpAndSettle();
    expect(find.text('hablar'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'comer');
    await tester.pump();
    expect(find.text('hablar'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('primary failure retries through the VM failed-page target',
      (tester) async {
    final reader = _QueryPort();
    await tester.pumpWidget(_app(reader));

    await tester.enterText(find.byType(TextField), 'hablar');
    await tester.pump();
    reader.failNext();
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(reader.pending, hasLength(1));
    expect(reader.queries.last.page, 0);
  });

  testWidgets(
      'uses CatalogWordRef callbacks and displays two of four suggestions',
      (tester) async {
    final reader = _QueryPort();
    CatalogWordRef? openedWord;
    CatalogWordRef? quizWord;
    String? quizHint;
    await tester.pumpWidget(
      _app(
        reader,
        onOpenWordDetail: (word) => openedWord = word,
        onOpenQuiz: (word, hint) {
          quizWord = word;
          quizHint = hint;
        },
      ),
    );

    await tester.enterText(find.byType(TextField), 'hab');
    await tester.pump();
    reader.completeNext(_pageWithSuggestions());
    await tester.pumpAndSettle();

    expect(find.text('verb10'), findsOneWidget);
    expect(find.text('verb11'), findsOneWidget);
    expect(find.text('verb12'), findsNothing);
    expect(find.text('verb13'), findsNothing);

    await tester.tap(find.text('verb10'));
    expect(
      openedWord,
      const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 10),
    );

    await tester.tap(find.text('Quiz').first);
    expect(
      quizWord,
      const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 10),
    );
    expect(quizHint, 'verb10');
  });

  test('presentation entry exports only the controlled Search widget', () {
    final source = File(
      'lib/features/search/port/presentation_entry.dart',
    ).readAsStringSync();

    expect(source, contains('show SearchFragment'));
    expect(source, isNot(contains('provider')));
    expect(source, isNot(contains('viewmodel')));
    expect(source, isNot(contains('view_model')));
  });
}

Widget _app(
  _QueryPort reader, {
  ValueChanged<CatalogWordRef>? onOpenWordDetail,
  void Function(CatalogWordRef word, String? displayHint)? onOpenQuiz,
}) =>
    ProviderScope(
      child: MaterialApp(
        home: SearchFragment(
          reader: reader,
          onOpenWordDetail: onOpenWordDetail ?? (_) {},
          onOpenQuiz: onOpenQuiz ?? (_, __) {},
        ),
      ),
    );

SearchResultPage _page(String word) => SearchResultPage(
      direction: SearchDirection.espJpn,
      items: [
        SearchResultItem(
          word: const CatalogWordRef(
            catalogId: CatalogId.espJpnMain,
            wordId: 1,
          ),
          headword: word,
          hasConjugation: false,
          meaningText: word,
          rankingNo: null,
          starCount: null,
        ),
      ],
      conjugationSuggestions: const [],
      hasNext: false,
      issues: const [],
    );

SearchResultPage _pageWithSuggestions() => SearchResultPage(
      direction: SearchDirection.espJpn,
      items: const [],
      conjugationSuggestions: [
        for (var id = 10; id < 14; id++)
          SearchConjugationSuggestion(
            word: CatalogWordRef(
              catalogId: CatalogId.espJpnMain,
              wordId: id,
            ),
            headword: 'verb$id',
            matches: const {
              SearchConjugationMatchKey.indicativePresentYo: 'form',
            },
          ),
      ],
      hasNext: false,
      issues: const [],
    );

final class _QueryPort implements SearchReaderPort {
  final queries = <SearchQuery>[];
  final pending = <Completer<Result<SearchResultPage>>>[];

  @override
  Future<Result<SearchResultPage>> search(SearchQuery query) {
    queries.add(query);
    final result = Completer<Result<SearchResultPage>>();
    pending.add(result);
    return result.future;
  }

  void completeNext(SearchResultPage page) =>
      pending.removeAt(0).complete(Result.success(page));

  void failNext() => pending.removeAt(0).complete(
        const Result.failure(SearchDataUnavailableError()),
      );
}
