import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/ranking/internal/domain/ranking_filter_selection.dart';
import 'package:my_dic/features/ranking/internal/presentation/view_model/new_ranking_view_model.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';

void main() {
  group('RankingViewModel', () {
    test('uses typed filters and resets paging state', () async {
      final reader = _ImmediateReader(_page([_item(1)], hasMore: true));
      final viewModel = RankingViewModel(reader, _scope);
      await viewModel.loadNextPage(0);

      viewModel.setPartOfSpeechFilter(
        RankingPartOfSpeech.noun,
        RankingFilterSelection.include,
      );
      viewModel.setStatusFilter(
        RankingStatusFilter.learned,
        RankingFilterSelection.exclude,
      );
      viewModel.setGroupByCatalogWord(true);

      expect(viewModel.state.currentPage, -1);
      expect(viewModel.state.items, isEmpty);
      expect(viewModel.state.filter.includedPartsOfSpeech,
          {RankingPartOfSpeech.noun});
      expect(viewModel.state.filter.excludedStatuses,
          {RankingStatusFilter.learned});
      expect(viewModel.state.filter.groupByCatalogWord, isTrue);
      viewModel.dispose();
    });

    test('page zero replaces and following pages append by stable item id',
        () async {
      final reader = _QueueReader([
        _page([_item(1), _item(2)], hasMore: true),
        _page([_item(2), _item(3)], hasMore: false),
      ]);
      final viewModel = RankingViewModel(reader, _scope);

      await viewModel.loadNextPage(0);
      await viewModel.loadNextPage(1);

      expect(viewModel.state.items.map((item) => item.id.toSerialized()),
          [1, 2, 3]);
      expect(viewModel.state.hasNext, isFalse);
      viewModel.dispose();
    });

    test('same request is single-flight and filter reset rejects late result',
        () async {
      final reader = _PendingReader();
      final viewModel = RankingViewModel(reader, _scope);
      final first = viewModel.loadNextPage(0);
      final duplicate = await viewModel.loadNextPage(0);
      expect(duplicate, isFalse);
      expect(reader.queries, hasLength(1));

      viewModel.setStatusFilter(
        RankingStatusFilter.bookmarked,
        RankingFilterSelection.include,
      );
      reader.complete(_page([_item(1)], hasMore: false));

      expect(await first, isFalse);
      expect(viewModel.state.items, isEmpty);
      viewModel.dispose();
    });

    test('retry repeats the failed page identity', () async {
      final reader = _QueueReader([
        const Result.failure(RankingReadError.catalogUnavailable()),
        _page([_item(4)], hasMore: false),
      ]);
      final viewModel = RankingViewModel(reader, _scope);

      expect(await viewModel.loadNextPage(3), isFalse);
      expect(await viewModel.retry(), isFalse);
      expect(reader.queries.map((query) => query.page), [3, 3]);
      expect(viewModel.state.items.single.id.toSerialized(), 4);
      viewModel.dispose();
    });
  });
}

const _scope = SessionScopeKey(accountScope: 'account-a', epoch: 1);

RankingPage _page(List<RankingItem> items, {required bool hasMore}) =>
    RankingPage(items: items, hasMore: hasMore);

RankingItem _item(int id) => RankingItem(
      id: RankingItemId.fromSerialized(id),
      word: CatalogWordRef(
        catalogId: CatalogId.espJpnMain,
        wordId: id,
      ),
      rank: id,
      rankedWord: 'word $id',
      lemma: 'lemma $id',
      hasConjugation: false,
    );

final class _ImmediateReader implements RankingPageQueryPort {
  _ImmediateReader(this.page);
  final RankingPage page;
  @override
  Future<Result<RankingPage>> readPage(RankingPageQuery query) async =>
      Result.success(page);
}

final class _QueueReader implements RankingPageQueryPort {
  _QueueReader(List<Object> results) : _results = [...results];
  final List<Object> _results;
  final List<RankingPageQuery> queries = [];
  @override
  Future<Result<RankingPage>> readPage(RankingPageQuery query) async {
    queries.add(query);
    final next = _results.removeAt(0);
    return next is RankingPage
        ? Result.success(next)
        : next as Result<RankingPage>;
  }
}

final class _PendingReader implements RankingPageQueryPort {
  final queries = <RankingPageQuery>[];
  final _completion = Completer<Result<RankingPage>>();
  @override
  Future<Result<RankingPage>> readPage(RankingPageQuery query) {
    queries.add(query);
    return _completion.future;
  }

  void complete(RankingPage page) => _completion.complete(Result.success(page));
}
