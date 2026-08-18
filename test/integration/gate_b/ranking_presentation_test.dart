import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/session/session_scope_provider.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/ranking/port/composition_contract.dart';
import 'package:my_dic/features/ranking/port/presentation_entry.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';

void main() {
  testWidgets('new session epoch fences the former page completion',
      (tester) async {
    final reader = _DeferredReader();
    const guest = SessionScopeKey(accountScope: guestAccountScope, epoch: 1);
    const account = SessionScopeKey(accountScope: 'account-a', epoch: 2);
    final session = StateProvider<SessionScopeKey?>((_) => guest);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionScopeKeyProvider.overrideWith((ref) => ref.watch(session)),
        ],
        child: MaterialApp(
          home: RankingFragment(
            ports: RankingPorts(reader: reader),
            wordStatusRenderer: (_) => const SizedBox.shrink(),
            onOpenWordDetail: (_) {},
            onOpenQuiz: (_, __) {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(reader.queries.single.scope, const RankingAccountScope.guest());

    final container = ProviderScope.containerOf(
      tester.element(find.byType(RankingFragment)),
    );
    container.read(session.notifier).state = account;
    await tester.pump();
    expect(reader.queries.last.scope, RankingAccountScope.account('account-a'));

    reader.complete(0, _page('stale'));
    await tester.pump();
    expect(find.text('stale'), findsNothing);
    expect(find.byKey(const ValueKey('ranking-card-1')), findsNothing);
    reader.complete(0, _page('current'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ranking-card-2')), findsOneWidget);
    // The unchanged card UI shows both the ranked form and lemma. This fixture
    // intentionally gives them the same label, so two Text widgets are valid.
    expect(find.text('current'), findsNWidgets(2));
  });
}

RankingPage _page(String label) => RankingPage(items: [
      RankingItem(
        id: RankingItemId.fromSerialized(label == 'stale' ? 1 : 2),
        word: CatalogWordRef(
          catalogId: CatalogId.espJpnMain,
          wordId: label == 'stale' ? 1 : 2,
        ),
        rank: 1,
        rankedWord: label,
        lemma: label,
        hasConjugation: false,
      ),
    ], hasMore: false);

final class _DeferredReader implements RankingPageQueryPort {
  final queries = <RankingPageQuery>[];
  final _pending = <Completer<Result<RankingPage>>>[];

  @override
  Future<Result<RankingPage>> readPage(RankingPageQuery query) {
    queries.add(query);
    final completion = Completer<Result<RankingPage>>();
    _pending.add(completion);
    return completion.future;
  }

  void complete(int index, RankingPage page) =>
      _pending.removeAt(index).complete(Result.success(page));
}
