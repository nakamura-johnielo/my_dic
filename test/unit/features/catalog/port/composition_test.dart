import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/catalog/port/composition.dart';

void main() {
  test('factory constructs every Catalog reader from typed dependencies', () {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final ports = createCatalogComposition(
      dependencies: CatalogDependencies(database: database),
    );

    expect(
      ports.entryDetail,
      isA<CatalogEntryDetailQueryPort>(),
    );
    expect(
      ports.conjugation,
      isA<CatalogConjugationQueryPort>(),
    );
    expect(
      ports.wordSearch,
      isA<CatalogWordSearchQueryPort>(),
    );
    expect(
      ports.conjugationSearch,
      isA<CatalogConjugationSearchQueryPort>(),
    );
    expect(
      ports.entrySummary,
      isA<CatalogEntrySummaryQueryPort>(),
    );
    expect(
      ports.ranking,
      isA<CatalogRankingQueryPort>(),
    );
    expect(
      ports.rankedEntries,
      isA<CatalogRankedEntryFeedQueryPort>(),
    );
    expect(
      ports.semanticEntryDetail,
      isA<CatalogSemanticEntryDetailQueryPort>(),
    );
  });

  test('composition is a pure holder for Catalog public capabilities', () {
    final reader = _EntryDetailQueryPort();
    final conjugations = _ConjugationQueryPort();
    final wordSearch = _WordSearchQueryPort();
    final conjugationSearch = _ConjugationSearchQueryPort();
    final entrySummary = _EntrySummaryQueryPort();
    final ranking = _RankingQueryPort();
    final rankedEntries = _RankedEntryFeedQueryPort();
    final semanticEntryDetail = _SemanticEntryDetailQueryPort();
    final readPorts = CatalogReadPorts(
      entryDetail: reader,
      conjugation: conjugations,
      wordSearch: wordSearch,
      conjugationSearch: conjugationSearch,
      entrySummary: entrySummary,
      ranking: ranking,
      rankedEntries: rankedEntries,
      semanticEntryDetail: semanticEntryDetail,
    );

    expect(readPorts.entryDetail, same(reader));
    expect(readPorts.conjugation, same(conjugations));
    expect(readPorts.wordSearch, same(wordSearch));
    expect(readPorts.conjugationSearch, same(conjugationSearch));
    expect(readPorts.entrySummary, same(entrySummary));
    expect(readPorts.ranking, same(ranking));
    expect(readPorts.rankedEntries, same(rankedEntries));
    expect(
      readPorts.semanticEntryDetail,
      same(semanticEntryDetail),
    );
  });
}

final class _EntryDetailQueryPort implements CatalogEntryDetailQueryPort {
  @override
  Future<Result<CatalogEntryDetail>> readEntryDetail(CatalogWordRef word) =>
      throw UnimplementedError();
}

final class _ConjugationQueryPort implements CatalogConjugationQueryPort {
  @override
  Future<Result<bool>> hasConjugation(CatalogWordRef word) =>
      throw UnimplementedError();

  @override
  Future<Result<CatalogConjugation?>> readConjugation(CatalogWordRef word) =>
      throw UnimplementedError();
}

final class _WordSearchQueryPort implements CatalogWordSearchQueryPort {
  @override
  Future<Result<CatalogSearchPage<CatalogWordSearchHit>>> searchWords(
    CatalogWordSearchQuery query,
  ) =>
      throw UnimplementedError();
}

final class _ConjugationSearchQueryPort
    implements CatalogConjugationSearchQueryPort {
  @override
  Future<Result<CatalogSearchPage<CatalogConjugationSearchHit>>>
      searchConjugations(CatalogConjugationSearchQuery query) =>
          throw UnimplementedError();
}

final class _EntrySummaryQueryPort implements CatalogEntrySummaryQueryPort {
  @override
  Future<Result<Map<CatalogWordRef, CatalogHeadwordMetadata>>>
      readHeadwordMetadata(Iterable<CatalogWordRef> words) =>
          throw UnimplementedError();

  @override
  Future<Result<Map<CatalogWordRef, CatalogMeaningSummary>>> readMeanings(
    Iterable<CatalogWordRef> words,
  ) =>
      throw UnimplementedError();
}

final class _RankingQueryPort implements CatalogRankingQueryPort {
  @override
  Future<Result<Map<CatalogWordRef, CatalogRankingMetadata>>>
      readRankingMetadata(Iterable<CatalogWordRef> words) =>
          throw UnimplementedError();
}

final class _RankedEntryFeedQueryPort
    implements CatalogRankedEntryFeedQueryPort {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _SemanticEntryDetailQueryPort
    implements CatalogSemanticEntryDetailQueryPort {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
