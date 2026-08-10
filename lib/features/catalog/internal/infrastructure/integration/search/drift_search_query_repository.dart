import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/conjugation/conjugation_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/catalog_html_text.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/search_query_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/catalog_ranking_lookup.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/raw_search_reader.dart';

/// Drift-backed implementation of Catalog's raw Search capability.
///
/// This boundary exposes only Catalog value objects; consumer paging, display,
/// and partial-failure policy stay outside Catalog.
final class DriftCatalogRawSearchReaderPort implements CatalogRawSearchReaderPort {
  DriftCatalogRawSearchReaderPort(
    this._dao,
    this._espJpnDictionary,
    this._jpnEspDictionary,
    this._conjugations,
    this._rankingLookup,
  );

  final CatalogRawSearchDao _dao;
  final IEsjDictionaryLocalDataSource _espJpnDictionary;
  final IJpnEspDictionaryLocalDataSource _jpnEspDictionary;
  final IConjugacionLocalDataSource _conjugations;
  final CatalogRankingLookup _rankingLookup;

  @override
  Future<List<CatalogPrimaryRawHit>> searchPrimary(
    CatalogRawSearchQuery query,
  ) =>
      _dao.fetchPrimary(query);

  @override
  Future<List<CatalogConjugationRawHit>> searchConjugations(
    CatalogRawSearchQuery query,
  ) =>
      _dao.fetchConjugationSuggestions(query);

  @override
  Future<Map<CatalogWordRef, String>> getMeanings(
    Iterable<CatalogWordRef> words,
  ) async {
    final grouped = _groupWordIds(words);
    final result = <CatalogWordRef, String>{};
    final espIds = grouped[CatalogId.espJpnMain] ?? const <int>[];
    if (espIds.isNotEmpty) {
      final sources = await Future.wait([
        _conjugations.getMeaningsByWordIds(espIds),
        _espJpnDictionary.getFirstContentsByWordIds(espIds),
      ]);
      final meanings = Map<int, String>.from(sources[0]);
      for (final entry in sources[1].entries) {
        meanings.putIfAbsent(
          entry.key,
          () => extractCatalogMeaningText(entry.value),
        );
      }
      meanings.removeWhere((_, value) => value.isEmpty);
      for (final entry in meanings.entries) {
        result[_espWord(entry.key)] = entry.value;
      }
    }
    final jpnIds = grouped[CatalogId.jpnEspMain] ?? const <int>[];
    if (jpnIds.isNotEmpty) {
      final contents = await _jpnEspDictionary.getContentsByWordIds(jpnIds);
      for (final entry in contents.entries) {
        final meaning = extractCatalogMeaningText(entry.value);
        if (meaning.isNotEmpty) result[_jpnWord(entry.key)] = meaning;
      }
    }
    return result;
  }

  @override
  Future<Map<CatalogWordRef, String>> getHeadwords(
    Iterable<CatalogWordRef> words,
  ) async {
    final ids = _groupWordIds(words)[CatalogId.espJpnMain] ?? const <int>[];
    if (ids.isEmpty) return const {};
    final headwords = await _espJpnDictionary.getFirstHeadwordsByWordIds(ids);
    return {
      for (final entry in headwords.entries) _espWord(entry.key): entry.value
    };
  }

  @override
  Future<Map<CatalogWordRef, int>> getRankingMetadata(
    Iterable<CatalogWordRef> words,
  ) async {
    final ids = _groupWordIds(words)[CatalogId.espJpnMain] ?? const <int>[];
    if (ids.isEmpty) return const {};
    final rankings = await _rankingLookup.getRankingNosByWordIds(ids);
    return {
      for (final entry in rankings.entries) _espWord(entry.key): entry.value
    };
  }
}

Map<CatalogId, List<int>> _groupWordIds(Iterable<CatalogWordRef> words) {
  final grouped = <CatalogId, List<int>>{};
  for (final word in words) {
    grouped.putIfAbsent(word.catalogId, () => <int>[]).add(word.wordId);
  }
  return grouped;
}

CatalogWordRef _espWord(int wordId) =>
    CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: wordId);

CatalogWordRef _jpnWord(int wordId) =>
    CatalogWordRef(catalogId: CatalogId.jpnEspMain, wordId: wordId);
