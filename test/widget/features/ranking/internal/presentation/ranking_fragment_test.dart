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
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';

void main() {
  testWidgets(
      'only reloads page zero for a filter change, not query state transitions',
      (tester) async {
    final loader = _DeferredLoader();
    const scope = SessionScopeKey(accountScope: 'guest', epoch: 4);
    final container = ProviderContainer(overrides: [
      sessionScopeKeyProvider.overrideWithValue(scope),
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

    expect(loader.inputs.map((input) => input.page), [0]);

    // Completing page zero changes loading to data. It must not look like a
    // filter change and reset the infinity-scroll controller.
    loader.completeNext();
    await _pumpFrames(tester);

    expect(loader.inputs.map((input) => input.page), [0]);

    container
        .read(rankingViewModelProvider(scope).notifier)
        .addFilter(CatalogPartOfSpeech.noun);
    await _pumpFrames(tester);

    // A real filter change resets once and the controller loads its first
    // page once. Keep that request pending so repeated resets are observable.
    expect(loader.inputs.map((input) => input.page), [0, 0]);
    expect(
        loader.inputs.last.partOfSpeechFilters, {CatalogPartOfSpeech.noun: 1});
  });
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var frame = 0; frame < 3; frame++) {
    await tester.pump();
  }
}

class _DeferredLoader implements ILoadRankingsUseCase {
  final inputs = <LoadRankingsInputData>[];
  final _pending = <Completer<Result<RankingPage>>>[];

  @override
  Future<Result<RankingPage>> execute(LoadRankingsInputData input) {
    inputs.add(input);
    final completer = Completer<Result<RankingPage>>();
    _pending.add(completer);
    return completer.future;
  }

  void completeNext() => _pending.removeAt(0).complete(
        Result.success(RankingPage(items: const [], hasNext: false)),
      );
}

class _Updater implements IUpdateRankingFilterUseCase {
  const _Updater();

  @override
  UpdateRankingFilterOutputData execute(UpdateRankingFilterInputData input) =>
      UpdateRankingFilterOutputData(input.data, input.filterType);
}
