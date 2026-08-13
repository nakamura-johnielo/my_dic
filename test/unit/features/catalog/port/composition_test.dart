import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_reader.dart';
import 'package:my_dic/features/catalog/port/catalog_read_ports.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/composition.dart';
import 'package:my_dic/features/catalog/port/conjugation_reader.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/catalog/port/model/catalog_entry_detail.dart';
import 'package:my_dic/features/catalog/port/model/catalog_search_models.dart';
import 'package:my_dic/features/catalog/port/query/catalog_conjugation_search_query.dart';
import 'package:my_dic/features/catalog/port/query/catalog_word_search_query.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_conjugation_reader_port.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_conjugation_search_reader_port.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_entry_detail_reader_port.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_entry_summary_reader_port.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_ranking_reader_port.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_word_search_reader_port.dart';
import 'package:my_dic/features/catalog/port/result/catalog_search_page.dart';

void main() {
  test('composition is a pure holder for Catalog public capabilities', () {
    final reader = _CatalogQueryPort();
    final conjugations = _ConjugationQueryPort();
    final wordSearch = _WordSearchQueryPort();
    final conjugationSearch = _ConjugationSearchQueryPort();
    final entrySummary = _EntrySummaryQueryPort();
    final ranking = _RankingQueryPort();
    final readPorts = CatalogReadPorts(
      entryDetail: reader,
      conjugation: conjugations,
      wordSearch: wordSearch,
      conjugationSearch: conjugationSearch,
      entrySummary: entrySummary,
      ranking: ranking,
    );

    final composition = CatalogComposition(
      readPorts: readPorts,
      catalogQueryPort: reader,
      conjugationQueryPort: conjugations,
    );

    expect(composition.readPorts, same(readPorts));
    expect(composition.readPorts.entryDetail, same(reader));
    expect(composition.readPorts.conjugation, same(conjugations));
    expect(composition.readPorts.wordSearch, same(wordSearch));
    expect(composition.readPorts.conjugationSearch, same(conjugationSearch));
    expect(composition.readPorts.entrySummary, same(entrySummary));
    expect(composition.readPorts.ranking, same(ranking));
    expect(composition.catalogQueryPort, same(reader));
    expect(composition.conjugationQueryPort, same(conjugations));
  });
}

final class _CatalogQueryPort
    implements CatalogQueryPort, CatalogEntryDetailQueryPort {
  @override
  Future<Result<CatalogEntryDetail>> getEntryDetail(CatalogWordRef word) =>
      throw UnimplementedError();

  @override
  Future<Result<CatalogEntryDetail>> readEntryDetail(CatalogWordRef word) =>
      throw UnimplementedError();
}

final class _ConjugationQueryPort
    implements ConjugationQueryPort, CatalogConjugationQueryPort {
  @override
  Future<Result<CatalogConjugation?>> getConjugation(CatalogWordRef word) =>
      throw UnimplementedError();

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
