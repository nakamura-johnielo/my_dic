import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/conjugation/conjugation_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/catalog_html_text.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/catalog_ranking_lookup.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/raw_quiz_candidate_reader.dart';

/// Drift-backed implementation of Catalog's raw Quiz candidate capability.
///
/// Consumer paging and all failure/display policy remain outside this Catalog
/// adapter.
final class DriftCatalogRawQuizCandidateReader
    implements CatalogRawQuizCandidateReader {
  DriftCatalogRawQuizCandidateReader(
    this._conjugations,
    this._dictionary,
    this._rankingLookup,
  );

  final IConjugacionLocalDataSource _conjugations;
  final IEsjDictionaryLocalDataSource _dictionary;
  final CatalogRankingLookup _rankingLookup;

  @override
  Future<List<CatalogRawQuizCandidateHit>> searchQuizCandidates(
    CatalogRawQuizCandidateQuery query,
  ) async =>
      (await _conjugations.searchConjugationsAcrossCatalog(
        query.text.trim(),
        query.size,
        query.page,
      ))
          .map(
            (row) => CatalogRawQuizCandidateHit(
              word: _word(row.wordId),
              headword: row.word,
            ),
          )
          .toList(growable: false);

  @override
  Future<Map<CatalogWordRef, String>> getQuizCandidateMeanings(
    Iterable<CatalogWordRef> words,
  ) async {
    final ids = _espIds(words);
    if (ids.isEmpty) return const {};
    final sources = await Future.wait([
      _conjugations.getMeaningsByWordIds(ids),
      _dictionary.getFirstContentsByWordIds(ids),
    ]);
    final values = Map<int, String>.from(sources[0]);
    for (final entry in sources[1].entries) {
      values.putIfAbsent(
        entry.key,
        () => extractCatalogMeaningText(entry.value),
      );
    }
    values.removeWhere((_, value) => value.isEmpty);
    return {for (final entry in values.entries) _word(entry.key): entry.value};
  }

  @override
  Future<Map<CatalogWordRef, String>> getQuizCandidateHeadwords(
    Iterable<CatalogWordRef> words,
  ) async {
    final ids = _espIds(words);
    if (ids.isEmpty) return const {};
    final values = await _dictionary.getFirstHeadwordsByWordIds(ids);
    return {for (final entry in values.entries) _word(entry.key): entry.value};
  }

  @override
  Future<Map<CatalogWordRef, int>> getQuizCandidateRankingMetadata(
    Iterable<CatalogWordRef> words,
  ) async {
    final ids = _espIds(words);
    if (ids.isEmpty) return const {};
    final rankings = await _rankingLookup.getRankingNosByWordIds(ids);
    return {
      for (final entry in rankings.entries) _word(entry.key): entry.value,
    };
  }
}

List<int> _espIds(Iterable<CatalogWordRef> words) => [
      for (final word in words)
        if (word.catalogId == CatalogId.espJpnMain) word.wordId,
    ];

CatalogWordRef _word(int wordId) =>
    CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: wordId);
