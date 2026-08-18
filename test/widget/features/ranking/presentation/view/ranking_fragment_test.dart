import 'dart:async';

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

    expect(find.text('word 1'), findsNWidgets(2));
    expect(find.byKey(const ValueKey('status-renderer')), findsOneWidget);
    expect(statusWord, _word);
    await tester.tap(find.byKey(const ValueKey('ranking-card-1')));
    expect(openedWord, _word);
    expect(reader.queries.single.page, 0);
  });

  testWidgets('restarts the first-page load when ports are replaced',
      (tester) async {
    final oldReader = _DeferredReader();
    final newReader = _Reader(label: 'new word', itemId: 2);
    final harnessKey = GlobalKey<_RankingFragmentHarnessState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionScopeKeyProvider.overrideWithValue(_scope)],
        child: MaterialApp(
          home: _RankingFragmentHarness(
            key: harnessKey,
            ports: RankingPorts(reader: oldReader),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(oldReader.queries.single.page, 0);

    harnessKey.currentState!.replacePorts(RankingPorts(reader: newReader));
    await tester.pumpAndSettle();

    expect(newReader.queries.single.page, 0);
    expect(find.text('new word'), findsNWidgets(2));
    expect(find.byKey(const ValueKey('ranking-card-2')), findsOneWidget);

    oldReader.complete(_page('old word', itemId: 1));
    await tester.pumpAndSettle();

    expect(find.text('old word'), findsNothing);
    expect(find.byKey(const ValueKey('ranking-card-1')), findsNothing);
  });
}

const _scope = SessionScopeKey(accountScope: 'account-a', epoch: 1);
const _word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 1);

final class _RankingFragmentHarness extends StatefulWidget {
  const _RankingFragmentHarness({super.key, required this.ports});

  final RankingPorts ports;

  @override
  State<_RankingFragmentHarness> createState() =>
      _RankingFragmentHarnessState();
}

final class _RankingFragmentHarnessState
    extends State<_RankingFragmentHarness> {
  late RankingPorts _ports = widget.ports;

  void replacePorts(RankingPorts ports) => setState(() => _ports = ports);

  @override
  Widget build(BuildContext context) => RankingFragment(
        ports: _ports,
        wordStatusRenderer: (_) => const SizedBox.shrink(),
        onOpenWordDetail: (_) {},
        onOpenQuiz: (_, __) {},
      );
}

final class _Reader implements RankingPageQueryPort {
  _Reader({this.label = 'word 1', this.itemId = 1});

  final String label;
  final int itemId;
  final queries = <RankingPageQuery>[];

  @override
  Future<Result<RankingPage>> readPage(RankingPageQuery query) async {
    queries.add(query);
    return Result.success(_page(label, itemId: itemId));
  }
}

RankingPage _page(String label, {required int itemId}) => RankingPage(
      items: [
        RankingItem(
          id: RankingItemId.fromSerialized(itemId),
          word: CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: itemId),
          rank: 1,
          rankedWord: label,
          lemma: label,
          hasConjugation: false,
        ),
      ],
      hasMore: false,
    );

final class _DeferredReader implements RankingPageQueryPort {
  final queries = <RankingPageQuery>[];
  final _completion = Completer<Result<RankingPage>>();

  @override
  Future<Result<RankingPage>> readPage(RankingPageQuery query) {
    queries.add(query);
    return _completion.future;
  }

  void complete(RankingPage page) => _completion.complete(Result.success(page));
}
