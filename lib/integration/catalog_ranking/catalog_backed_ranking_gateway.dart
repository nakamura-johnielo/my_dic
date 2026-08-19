import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';

/// Catalogのランク付きエントリフィードをRankingへ変換する純粋な契約アダプター。
final class CatalogBackedRankingGateway implements RankingCatalogGateway {
  const CatalogBackedRankingGateway(this._catalog);

  final CatalogRankedEntryFeedQueryPort _catalog;

  @override
  Future<Result<RankingCatalogChunk>> readChunk(
    RankingCatalogChunkQuery query,
  ) async {
    try {
      final result = await _catalog.readRankedEntries(
        CatalogRankedEntryFeedQuery(
          offset: query.offset,
          size: query.size,
        ),
      );
      if (result case Success<CatalogRankedEntryFeed>(data: final feed)) {
        try {
          return Result.success(
            RankingCatalogChunk(
              items: feed.items.map(_entry),
              hasMore: feed.hasMore,
            ),
          );
        } catch (error, stackTrace) {
          return Result.failure(
            RankingCatalogGatewayError(
              kind: RankingCatalogGatewayFailureKind.invalidData,
              message: 'Catalog returned an invalid ranking source item.',
              originalError: error,
              stackTrace: stackTrace,
            ),
          );
        }
      }
      final error = result.errorOrNull!;
      return Result.failure(_error(error));
    } catch (error, stackTrace) {
      return Result.failure(
        RankingCatalogGatewayError(
          kind: RankingCatalogGatewayFailureKind.unexpected,
          message: 'Catalog ranking data could not be read.',
          originalError: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

RankingCatalogEntry _entry(CatalogRankedEntry entry) => RankingCatalogEntry(
      id: RankingItemId.fromSerialized(entry.entryRef.toSerialized()),
      word: entry.word,
      rank: entry.rankingNo,
      rankedWord: entry.rankedWord,
      lemma: entry.lemma,
      partsOfSpeech: entry.partsOfSpeech.map(_partOfSpeech),
      hasConjugation: entry.hasConjugation,
    );

RankingPartOfSpeech _partOfSpeech(CatalogPartOfSpeech value) => switch (value) {
      CatalogPartOfSpeech.noun => RankingPartOfSpeech.noun,
      CatalogPartOfSpeech.abbreviation => RankingPartOfSpeech.abbreviation,
      CatalogPartOfSpeech.preposition => RankingPartOfSpeech.preposition,
      CatalogPartOfSpeech.prefix => RankingPartOfSpeech.prefix,
      CatalogPartOfSpeech.adjective => RankingPartOfSpeech.adjective,
      CatalogPartOfSpeech.verb => RankingPartOfSpeech.verb,
      CatalogPartOfSpeech.adverb => RankingPartOfSpeech.adverb,
      CatalogPartOfSpeech.interjection => RankingPartOfSpeech.interjection,
      CatalogPartOfSpeech.participle => RankingPartOfSpeech.participle,
      CatalogPartOfSpeech.pronoun => RankingPartOfSpeech.pronoun,
      CatalogPartOfSpeech.conjunction => RankingPartOfSpeech.conjunction,
      CatalogPartOfSpeech.article => RankingPartOfSpeech.article,
      CatalogPartOfSpeech.auxiliaryVerb => RankingPartOfSpeech.auxiliaryVerb,
      CatalogPartOfSpeech.none => RankingPartOfSpeech.none,
    };

RankingCatalogGatewayError _error(Object error) {
  final kind = switch (error) {
    CatalogDataCorruptedError() =>
      RankingCatalogGatewayFailureKind.invalidData,
    CatalogDataUnavailableError() =>
      RankingCatalogGatewayFailureKind.unavailable,
    _ => RankingCatalogGatewayFailureKind.unexpected,
  };
  return RankingCatalogGatewayError(
    kind: kind,
    message: error is CatalogReadError
        ? error.message
        : 'Catalog ranking data could not be read.',
    originalError: error,
    stackTrace: error is CatalogReadError ? error.stackTrace : null,
  );
}
