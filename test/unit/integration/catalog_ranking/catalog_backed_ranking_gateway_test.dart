import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';
import 'package:my_dic/integration/catalog_ranking/catalog_backed_ranking_gateway.dart';

void main() {
  test('maps identity, values, taxonomy, and source look-ahead', () async {
    final gateway = CatalogBackedRankingGateway(
      _CatalogFeed(
        Result.success(
          CatalogRankedEntryFeed(
            items: [
              CatalogRankedEntry(
                entryRef: CatalogRankingEntryRef.fromSerialized(7),
                word: _word(2),
                rankingNo: 3,
                rankedWord: 'hablo',
                lemma: 'hablar',
                partsOfSpeech: const {
                  CatalogPartOfSpeech.verb,
                  CatalogPartOfSpeech.abbreviation,
                },
                hasConjugation: true,
              ),
            ],
            hasMore: true,
          ),
        ),
      ),
    );

    final result = await gateway.readChunk(
      RankingCatalogChunkQuery(offset: 4, size: 2),
    );

    expect(result.dataOrNull?.hasMore, isTrue);
    final entry = result.dataOrNull!.items.single;
    expect(entry.id.toSerialized(), 7);
    expect(entry.word, _word(2));
    expect(entry.partsOfSpeech, {
      RankingPartOfSpeech.verb,
      RankingPartOfSpeech.abbreviation,
    });
  });

  test('maps provider corruption and conversion failures to typed errors',
      () async {
    final providerFailure = CatalogBackedRankingGateway(
      _CatalogFeed(
        const Result.failure(CatalogDataCorruptedError()),
      ),
    );
    final invalidEntry = CatalogBackedRankingGateway(
      _CatalogFeed(
        Result.success(
          CatalogRankedEntryFeed(
            items: [
              CatalogRankedEntry(
                entryRef: CatalogRankingEntryRef.fromSerialized(1),
                word: _word(1),
                rankingNo: 0,
                rankedWord: 'invalid',
                lemma: 'invalid',
                partsOfSpeech: const {},
                hasConjugation: false,
              ),
            ],
            hasMore: false,
          ),
        ),
      ),
    );

    final corrupted = await providerFailure.readChunk(
      RankingCatalogChunkQuery(offset: 0, size: 1),
    );
    final invalid = await invalidEntry.readChunk(
      RankingCatalogChunkQuery(offset: 0, size: 1),
    );

    expect(
      (corrupted.errorOrNull as RankingCatalogGatewayError).kind,
      RankingCatalogGatewayFailureKind.invalidData,
    );
    expect(
      (invalid.errorOrNull as RankingCatalogGatewayError).kind,
      RankingCatalogGatewayFailureKind.invalidData,
    );
  });
}

CatalogWordRef _word(int id) => CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: id,
    );

final class _CatalogFeed implements CatalogRankedEntryFeedQueryPort {
  _CatalogFeed(this.result);

  final Result<CatalogRankedEntryFeed> result;
  CatalogRankedEntryFeedQuery? query;

  @override
  Future<Result<CatalogRankedEntryFeed>> readRankedEntries(
    CatalogRankedEntryFeedQuery query,
  ) async {
    this.query = query;
    return result;
  }
}
