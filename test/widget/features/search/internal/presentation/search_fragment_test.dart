import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/search/internal/presentation/view/search_fragment.dart';
import 'package:my_dic/features/search/port/model/search_direction.dart';
import 'package:my_dic/features/search/port/model/search_query.dart';
import 'package:my_dic/features/search/port/model/search_result_item.dart';
import 'package:my_dic/features/search/port/model/search_result_page.dart';
import 'package:my_dic/features/search/port/presentation_dependencies.dart';
import 'package:my_dic/features/search/port/reader.dart';

void main() {
  testWidgets('query change removes old results while the new page loads',
      (tester) async {
    final reader = _ReaderPort();
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
    final reader = _ReaderPort();
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
}

Widget _app(_ReaderPort reader) => ProviderScope(
      overrides: [searchReaderPortDependencyProvider.overrideWithValue(reader)],
      child: MaterialApp(
        home: SearchFragment(onOpenWordDetail: (_) {}, onOpenQuiz: (_, __) {}),
      ),
    );

SearchResultPage _page(String word) => SearchResultPage(
      items: [
        SearchResultItem(
          wordId: 1,
          word: const CatalogWordRef(
            catalogId: CatalogId.espJpnMain,
            wordId: 1,
          ),
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

final class _ReaderPort implements SearchReaderPort {
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
        Result.failure(DatabaseError(message: 'temporary failure')),
      );
}
