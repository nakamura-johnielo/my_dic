import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/session/session_scope_provider.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/internal/application/usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/features/ranking/internal/application/usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/features/ranking/internal/composition/usecase_di.dart';
import 'package:my_dic/features/ranking/internal/composition/view_model_di.dart';
import 'package:my_dic/features/ranking/internal/presentation/view/ranking_fragment.dart';
import 'package:my_dic/features/ranking/port/model/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/port/model/ranking_page.dart';
import 'package:my_dic/features/ranking/port/model/update_ranking_filter_input_data.dart';
import 'package:my_dic/features/ranking/port/model/update_ranking_filter_output_data.dart';

/// Gate B cross-layer coverage: the session key rekeys the entry and a stale
/// completion from the former entry cannot publish into the new one.
void main() {
  testWidgets('new session epoch starts a fresh page zero entry',
      (tester) async {
    final loader = _DeferredLoader();
    const first = SessionScopeKey(accountScope: 'guest', epoch: 1);
    const second = SessionScopeKey(accountScope: 'account-a', epoch: 2);
    final session = StateProvider<SessionScopeKey?>((_) => first);
    final container = ProviderContainer(overrides: [
      sessionScopeKeyProvider.overrideWith((ref) => ref.watch(session)),
      loadRankingsUseCaseProvider.overrideWithValue(loader),
      updateRankingFilterUseCaseProvider.overrideWithValue(const _Updater()),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: RankingFragment(onOpenWordDetail: (_) {}, onOpenQuiz: (_, __) {}),
      ),
    ));
    await tester.pump();
    expect(loader.inputs.map((input) => input.accountScope), ['guest']);

    container.read(session.notifier).state = second;
    await tester.pump();
    expect(loader.inputs.map((input) => input.accountScope),
        ['guest', 'account-a']);

    loader.complete(0);
    await tester.pump();
    expect(container.read(rankingViewModelProvider(second)).items, isEmpty);
    loader.complete(0);
    await tester.pumpAndSettle();
  });
}

class _DeferredLoader implements ILoadRankingsUseCase {
  final inputs = <LoadRankingsInputData>[];
  final _pending = <Completer<Result<RankingPage>>>[];

  @override
  Future<Result<RankingPage>> execute(LoadRankingsInputData input) {
    inputs.add(input);
    final completion = Completer<Result<RankingPage>>();
    _pending.add(completion);
    return completion.future;
  }

  void complete(int index) => _pending.removeAt(index).complete(
        Result.success(RankingPage(items: const [], hasNext: false)),
      );
}

class _Updater implements IUpdateRankingFilterUseCase {
  const _Updater();

  @override
  UpdateRankingFilterOutputData execute(UpdateRankingFilterInputData input) =>
      UpdateRankingFilterOutputData(input.data, input.filterType);
}
