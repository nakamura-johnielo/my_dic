import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';
import 'package:my_dic/features/ranking/internal/application/usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/features/ranking/internal/application/usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/features/ranking/internal/presentation/view_model/new_ranking_view_model.dart';
import 'package:my_dic/features/ranking/internal/presentation/view_model/ranking_page_identity.dart';
import 'package:my_dic/features/ranking/port/model/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/port/model/ranking_list_item.dart';
import 'package:my_dic/features/ranking/port/model/ranking_page.dart';
import 'package:my_dic/features/ranking/port/model/update_ranking_filter_input_data.dart';
import 'package:my_dic/features/ranking/port/model/update_ranking_filter_output_data.dart';

void main() {
  const scope = SessionScopeKey(accountScope: 'account-a', epoch: 1);

  test('normalized filter copies maps and has value equality', () {
    final partOfSpeech = {CatalogPartOfSpeech.noun: 1};
    final featureTags = {FeatureTag.isLearned: 1, FeatureTag.hasNote: 0};

    final snapshot = RankingNormalizedFilter(
      partOfSpeech: partOfSpeech,
      featureTags: featureTags,
    );
    partOfSpeech[CatalogPartOfSpeech.verb] = -1;
    featureTags[FeatureTag.isLearned] = -1;

    expect(snapshot.partOfSpeech, {CatalogPartOfSpeech.noun: 1});
    expect(snapshot.featureTags, {FeatureTag.isLearned: 1});
    expect(
      snapshot,
      RankingNormalizedFilter(
        partOfSpeech: {CatalogPartOfSpeech.noun: 1},
        featureTags: {FeatureTag.isLearned: 1},
      ),
    );
    expect(
      () => snapshot.partOfSpeech[CatalogPartOfSpeech.adjective] = 1,
      throwsUnsupportedError,
    );
  });

  test('deduplicates an in-flight request for the same page identity',
      () async {
    final loader = _DeferredLoader();
    final vm = _vm(loader, scope);

    final first = vm.loadNextPage(0);
    final second = vm.loadNextPage(0);
    expect(loader.inputs, hasLength(1));

    loader.complete(0, _page([_item(1)]));
    await first;
    expect(await second, isFalse);
    expect(vm.state.items.map((item) => item.rankingId), [1]);
  });

  test('a filter reset fences an old completion and uses an immutable snapshot',
      () async {
    final loader = _DeferredLoader();
    final vm = _vm(loader, scope);

    final old = vm.loadNextPage(0);
    vm.setPartOfSpeechFilter(CatalogPartOfSpeech.noun, 1);
    final current = vm.loadNextPage(0);
    expect(loader.inputs[0].partOfSpeechFilters, isEmpty);
    expect(loader.inputs[1].partOfSpeechFilters, {CatalogPartOfSpeech.noun: 1});

    loader.complete(0, _page([_item(1, wordId: 99)]));
    await old;
    expect(vm.state.items, isEmpty);

    loader.complete(0, _page([_item(2)]));
    await current;
    expect(vm.state.items.map((item) => item.rankingId), [2]);
  });

  test('page zero replaces and page one appends with rankingId dedupe',
      () async {
    final loader = _DeferredLoader();
    final vm = _vm(loader, scope);

    final zero = vm.loadNextPage(0);
    loader.complete(0, _page([_item(10, wordId: 7)], hasNext: true));
    await zero;
    final one = vm.loadNextPage(1);
    loader.complete(
      0,
      _page([_item(11, wordId: 7), _item(10, wordId: 999)], hasNext: false),
    );
    await one;
    expect(vm.state.items.map((item) => item.rankingId), [10, 11]);

    final replacement = vm.loadNextPage(0);
    loader.complete(0, _page([_item(12)]));
    await replacement;
    expect(vm.state.items.map((item) => item.rankingId), [12]);
  });

  test('retry repeats the failed page identity once without page advance',
      () async {
    final loader = _DeferredLoader();
    final vm = _vm(loader, scope);

    final initial = vm.loadNextPage(0);
    loader.complete(0, _page([_item(1)], hasNext: true));
    await initial;
    final failed = vm.loadNextPage(1);
    loader.fail(0);
    await failed;

    final retry = vm.retry();
    expect(loader.inputs.map((input) => input.page), [0, 1, 1]);
    loader.complete(0, _page([_item(2)]));
    await retry;
    expect(vm.state.currentPage, 1);
    expect(vm.state.items.map((item) => item.rankingId), [1, 2]);
  });

  test('dispose fences a late completion', () async {
    final loader = _DeferredLoader();
    final vm = _vm(loader, scope);
    final pending = vm.loadNextPage(0);
    vm.dispose();
    loader.complete(0, _page([_item(1)]));
    expect(await pending, isFalse);
  });
}

RankingViewModel _vm(_DeferredLoader loader, SessionScopeKey scope) =>
    RankingViewModel(loader, const _FilterUpdater(), scope);

RankingListItem _item(int rankingId, {int? wordId}) => RankingListItem(
      rankingId: rankingId,
      rank: rankingId,
      rankedWord: 'word-$rankingId',
      lemma: 'word-$rankingId',
      wordId: wordId ?? rankingId,
      hasConjugation: false,
    );

RankingPage _page(List<RankingListItem> items, {bool hasNext = false}) =>
    RankingPage(items: items, hasNext: hasNext);

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

  void complete(int index, RankingPage page) =>
      _pending.removeAt(index).complete(Result.success(page));

  void fail(int index) => _pending.removeAt(index).complete(
        Result.failure(DatabaseError(message: 'temporary failure')),
      );
}

class _FilterUpdater implements IUpdateRankingFilterUseCase {
  const _FilterUpdater();

  @override
  UpdateRankingFilterOutputData execute(UpdateRankingFilterInputData input) =>
      UpdateRankingFilterOutputData(input.data, input.filterType);
}
