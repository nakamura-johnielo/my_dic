import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/ranking/internal/application/ranking_application_service.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';

void main() {
  group('RankingApplicationService', () {
    test('filters before paging with status include OR and exclude AND',
        () async {
      final service = _service(
        statuses: [
          RankingWordStatusFact(
            word: _word(1),
            isLearned: true,
            isBookmarked: false,
            hasNote: false,
          ),
          RankingWordStatusFact(
            word: _word(2),
            isLearned: false,
            isBookmarked: true,
            hasNote: false,
          ),
          RankingWordStatusFact(
            word: _word(3),
            isLearned: true,
            isBookmarked: false,
            hasNote: true,
          ),
        ],
      );
      final filter = RankingFilter(
        includedStatuses: {
          RankingStatusFilter.learned,
          RankingStatusFilter.bookmarked,
        },
        excludedStatuses: {RankingStatusFilter.hasNote},
      );

      final first = await service.readPage(_query(page: 0, filter: filter));
      final second = await service.readPage(_query(page: 1, filter: filter));

      expect(first.dataOrNull?.items.single.id.toSerialized(), 1);
      expect(first.dataOrNull?.hasMore, isTrue);
      expect(second.dataOrNull?.items.single.id.toSerialized(), 2);
      expect(second.dataOrNull?.hasMore, isTrue);
    });

    test('part-of-speech exclusion and grouping work across chunks', () async {
      final service = _service(statuses: const []);
      final result = await service.readPage(
        _query(
          page: 0,
          size: 10,
          filter: RankingFilter(
            excludedPartsOfSpeech: {RankingPartOfSpeech.verb},
            groupByCatalogWord: true,
          ),
        ),
      );

      expect(
        result.dataOrNull?.items.map((item) => item.id.toSerialized()),
        [1, 4, 5],
      );
      expect(result.dataOrNull?.hasMore, isFalse);
    });

    test('partial missing status is all-false absence policy', () async {
      final service = _service(statuses: const []);
      final included = await service.readPage(
        _query(
          page: 0,
          size: 10,
          filter: RankingFilter(
            includedStatuses: {RankingStatusFilter.learned},
          ),
        ),
      );
      final excluded = await service.readPage(
        _query(
          page: 0,
          size: 10,
          filter: RankingFilter(
            excludedStatuses: {RankingStatusFilter.learned},
          ),
        ),
      );

      expect(included.dataOrNull?.items, isEmpty);
      expect(excluded.dataOrNull?.items, hasLength(5));
    });

    test('normalizes provider failures and invalid source order', () async {
      final catalogFailure = RankingApplicationService(
        catalog: _FailingCatalog(),
        wordStatus: _StatusGateway(const []),
      );
      final invalidOrder = RankingApplicationService(
        catalog: _CatalogGateway([
          _entry(id: 2, wordId: 2, rank: 2),
          _entry(id: 1, wordId: 1, rank: 1),
        ]),
        wordStatus: _StatusGateway(const []),
      );

      final unavailable = await catalogFailure.readPage(_query(page: 0));
      final invalid = await invalidOrder.readPage(_query(page: 0));

      expect(
        (unavailable.errorOrNull as RankingReadError).kind,
        RankingReadFailureKind.catalogUnavailable,
      );
      expect(
        (invalid.errorOrNull as RankingReadError).kind,
        RankingReadFailureKind.invalidSourceItem,
      );
    });
  });
}

RankingApplicationService _service({
  required List<RankingWordStatusFact> statuses,
}) =>
    RankingApplicationService(
      catalog: _CatalogGateway([
        _entry(id: 1, wordId: 1, rank: 1),
        _entry(id: 2, wordId: 1, rank: 2),
        _entry(
          id: 3,
          wordId: 2,
          rank: 3,
          partOfSpeech: RankingPartOfSpeech.verb,
        ),
        _entry(id: 4, wordId: 3, rank: 4),
        _entry(id: 5, wordId: 4, rank: 5),
      ]),
      wordStatus: _StatusGateway(statuses),
      sourceChunkSize: 2,
    );

RankingPageQuery _query({
  required int page,
  int size = 1,
  RankingFilter? filter,
}) =>
    RankingPageQuery(
      page: page,
      size: size,
      scope: RankingAccountScope.account('account-a'),
      filter: filter,
    );

RankingCatalogEntry _entry({
  required int id,
  required int wordId,
  required int rank,
  RankingPartOfSpeech partOfSpeech = RankingPartOfSpeech.noun,
}) =>
    RankingCatalogEntry(
      id: RankingItemId.fromSerialized(id),
      word: _word(wordId),
      rank: rank,
      rankedWord: 'word $id',
      lemma: 'lemma $wordId',
      partsOfSpeech: {partOfSpeech},
      hasConjugation: false,
    );

CatalogWordRef _word(int id) => CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: id,
    );

final class _CatalogGateway implements RankingCatalogGateway {
  _CatalogGateway(this.items);

  final List<RankingCatalogEntry> items;

  @override
  Future<Result<RankingCatalogChunk>> readChunk(
    RankingCatalogChunkQuery query,
  ) async {
    final chunk = items.skip(query.offset).take(query.size).toList();
    return Result.success(
      RankingCatalogChunk(
        items: chunk,
        hasMore: query.offset + chunk.length < items.length,
      ),
    );
  }
}

final class _FailingCatalog implements RankingCatalogGateway {
  @override
  Future<Result<RankingCatalogChunk>> readChunk(
    RankingCatalogChunkQuery query,
  ) async =>
      const Result.failure(
        RankingCatalogGatewayError(
          kind: RankingCatalogGatewayFailureKind.unavailable,
          message: 'offline',
        ),
      );
}

final class _StatusGateway implements RankingWordStatusGateway {
  const _StatusGateway(this.statuses);

  final List<RankingWordStatusFact> statuses;

  @override
  Future<Result<RankingWordStatusBatch>> readBatch(
    RankingWordStatusBatchQuery query,
  ) async =>
      Result.success(RankingWordStatusBatch(statuses));
}
