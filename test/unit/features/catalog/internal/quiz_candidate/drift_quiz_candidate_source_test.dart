import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/conjugation/conjugation_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_dataset.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/quiz_candidate/drift_catalog_raw_quiz_candidate_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/catalog_ranking_lookup.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/raw_quiz_candidate_reader.dart';

void main() {
  test('returns trimmed, paged Catalog raw candidate hits', () async {
    final conjugations = _Conjugations(const [
      EspConjugationTableData(wordId: 7, word: 'hablar'),
    ]);
    final reader = _reader(conjugations);

    final hits = await reader.searchQuizCandidates(
      const CatalogRawQuizCandidateQuery(text: ' hablar ', page: 1, size: 2),
    );

    expect(conjugations.request, ('hablar', 2, 1));
    expect(hits.single.word,
        const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7));
    expect(hits.single.headword, 'hablar');
  });

  test('returns Catalog-owned enrichment values without Quiz DTOs', () async {
    final conjugations = _Conjugations(const [], meanings: {7: 'conjugation'});
    final reader = _reader(
      conjugations,
      dictionary: _Dictionary(
        contents: {8: '<p data-orgtag="meaning">dictionary</p>'},
        headwords: {7: 'hablar<sup>(**)</sup>'},
      ),
    );
    const word7 = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);
    const word8 = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 8);

    expect(await reader.getQuizCandidateMeanings([word7, word8]),
        {word7: 'conjugation', word8: 'dictionary'});
    expect(await reader.getQuizCandidateHeadwords([word7]),
        {word7: 'hablar<sup>(**)</sup>'});
  });

  test('delegates ranking metadata to the Catalog-owned lookup', () async {
    const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);
    final ranking = _Ranking({7: 3});
    final reader = _reader(_Conjugations(const []), ranking: ranking);

    expect(await reader.getQuizCandidateRankingMetadata([word]), {word: 3});
    expect(ranking.requestedWordIds, [7]);
  });
}

DriftCatalogRawQuizCandidateReaderPort _reader(
  _Conjugations conjugations, {
  _Dictionary? dictionary,
  CatalogRankingLookup? ranking,
}) =>
    DriftCatalogRawQuizCandidateReaderPort(
      conjugations,
      dictionary ?? _Dictionary(),
      ranking ?? _Ranking(const {}),
    );

final class _Ranking implements CatalogRankingLookup {
  _Ranking(this.values);

  final Map<int, int> values;
  List<int>? requestedWordIds;

  @override
  Future<Map<int, int>> getRankingNosByWordIds(List<int> wordIds) async {
    requestedWordIds = wordIds;
    return values;
  }
}

final class _Conjugations implements IConjugacionLocalDataSource {
  _Conjugations(this.rows, {this.meanings = const {}});
  final List<EspConjugationTableData> rows;
  final Map<int, String> meanings;
  (String, int, int)? request;
  @override
  Future<List<EspConjugationTableData>> searchConjugationsAcrossCatalog(
      String word, int size, int currentPage) async {
    request = (word, size, currentPage);
    return rows;
  }

  @override
  Future<Map<int, String>> getMeaningsByWordIds(List<int> wordIds) async =>
      meanings;
  @override
  Future<EspConjugationTableData?> getConjugacionByWordId(int id) async => null;
  @override
  Future<List<EspConjugationTableData>> getConjugacionByWordWithPage(
          String word, int size, int currentPage) async =>
      const [];
  @override
  Future<bool> existsConjByWordId(int wordId) async => false;
  @override
  Future<String?> getSimpleMeaningById(int id) async => null;
}

final class _Dictionary implements IEsjDictionaryLocalDataSource {
  _Dictionary({this.contents = const {}, this.headwords = const {}});
  final Map<int, String> contents;
  final Map<int, String> headwords;
  @override
  Future<Map<int, String>> getFirstContentsByWordIds(List<int> wordIds) async =>
      contents;
  @override
  Future<Map<int, String>> getFirstHeadwordsByWordIds(
          List<int> wordIds) async =>
      headwords;
  @override
  Future<List<EspJpnDictionaryDataSet>> getDictionaryByWordId(
          int wordId) async =>
      const [];
  @override
  Future<String?> getFirstContentByWordId(int wordId) async => contents[wordId];
  @override
  Future<String?> getFirstHeadwordByWordId(int wordId) async =>
      headwords[wordId];
  @override
  Future<String?> getHeadwordById(int id) async => null;
  @override
  Future<String?> getSimpleMeaningById(int id) async => null;
}
