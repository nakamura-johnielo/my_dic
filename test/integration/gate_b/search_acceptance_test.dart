import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/search/port/model/search_direction.dart';
import 'package:my_dic/features/search/port/model/search_query.dart';
import 'package:my_dic/features/search/port/model/search_result_item.dart';
import 'package:my_dic/features/search/port/model/search_result_page.dart';
import 'package:my_dic/features/search/port/presentation_dependencies.dart';
import 'package:my_dic/features/search/port/presentation_entry.dart';
import 'package:my_dic/features/search/port/reader.dart';

/// Gate B cross-layer acceptance: public presentation entry + app bridge fake.
void main() {
  testWidgets(
      'query change fences a stale bridge completion and retry is page 0',
      (tester) async {
    final bridge = _CatalogBridgeFake();
    await tester.pumpWidget(ProviderScope(
      overrides: [searchReaderDependencyProvider.overrideWithValue(bridge)],
      child: MaterialApp(
        home: SearchFragment(onOpenWordDetail: (_) {}, onOpenQuiz: (_, __) {}),
      ),
    ));

    await tester.enterText(find.byType(TextField), 'hablar');
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'comer');
    await tester.pump();

    bridge.completeAt(0, _page('old'));
    await tester.pump();
    expect(find.text('old'), findsNothing);

    bridge.failAt(0);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(bridge.queries.last.page, 0);
    expect(bridge.queries.last.text, 'comer');
  });
}

SearchResultPage _page(String word) => SearchResultPage(
      items: [
        SearchResultItem(
          wordId: 1,
          word:
              const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 1),
          headword: word,
          direction: SearchDirection.espJpn,
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

final class _CatalogBridgeFake implements SearchReader {
  final queries = <SearchQuery>[];
  final _pending = <Completer<Result<SearchResultPage>>>[];

  @override
  Future<Result<SearchResultPage>> search(SearchQuery query) {
    queries.add(query);
    final completion = Completer<Result<SearchResultPage>>();
    _pending.add(completion);
    return completion.future;
  }

  void completeAt(int index, SearchResultPage page) =>
      _pending.removeAt(index).complete(Result.success(page));

  void failAt(int index) => _pending.removeAt(index).complete(
        Result.failure(DatabaseError(message: 'temporary failure')),
      );
}
