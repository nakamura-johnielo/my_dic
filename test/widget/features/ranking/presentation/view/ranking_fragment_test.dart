import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/session/session_scope_provider.dart';
import 'package:my_dic/features/ranking/port/composition_contract.dart';
import 'package:my_dic/features/ranking/port/presentation_entry.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';

void main() {
  testWidgets('public entry renders typed items and navigation identities',
      (tester) async {
    CatalogWordRef? openedWord;
    CatalogWordRef? statusWord;
    final reader = _Reader();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionScopeKeyProvider.overrideWithValue(_scope),
        ],
        child: MaterialApp(
          home: RankingFragment(
            ports: RankingPorts(reader: reader),
            wordStatusRenderer: (word) {
              statusWord = word;
              return const SizedBox(key: ValueKey('status-renderer'));
            },
            onOpenWordDetail: (word) => openedWord = word,
            onOpenQuiz: (_, __) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('word 1'), findsOneWidget);
    expect(find.byKey(const ValueKey('status-renderer')), findsOneWidget);
    expect(statusWord, _word);
    await tester.tap(find.text('word 1'));
    expect(openedWord, _word);
    expect(reader.queries.single.page, 0);
  });
}

const _scope = SessionScopeKey(accountScope: 'account-a', epoch: 1);
const _word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 1);

final class _Reader implements RankingPageReaderPort {
  final queries = <RankingPageQuery>[];

  @override
  Future<Result<RankingPage>> readPage(RankingPageQuery query) async {
    queries.add(query);
    return Result.success(RankingPage(items: [
      RankingItem(
        id: RankingItemId.fromSerialized(1),
        word: _word,
        rank: 1,
        rankedWord: 'word 1',
        lemma: 'lemma 1',
        hasConjugation: false,
      ),
    ], hasMore: false));
  }
}
