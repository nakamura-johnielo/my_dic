import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/conjugation/conjugation_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_word_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_word_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/search_query_dao.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';
import 'package:my_dic/features/catalog/port/raw_search_reader.dart';

void main() {
  test('queries exactly the requested Catalog, preserving its paging boundary',
      () async {
    final esp = _EspWords([
      EspJpnWordTableData(
        wordId: 2,
        word: 'hablar',
        partOfSpeech: CatalogPartOfSpeech.verb.wireValue,
      ),
    ]);
    final jpn = _JpnWords(const [JpnEspWordTableData(wordId: 9, word: '話す')]);
    final dao = CatalogRawSearchDao(esp, jpn, _Conjugations());

    final hits = await dao.fetchPrimary(const CatalogRawSearchQuery(
      catalogId: CatalogId.espJpnMain,
      text: 'hab',
      page: 2,
      size: 20,
    ));

    expect(esp.request, ('hab', 20, 2, false));
    expect(jpn.request, isNull);
    expect(hits.single.word,
        const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 2));
    expect(hits.single.hasConjugation, isTrue);
  });

  test('exposes conjugation matches as stable Catalog wire keys', () async {
    final conjugations = _Conjugations(suggestions: const [
      EspConjugationTableData(
        wordId: 3,
        word: 'hablar',
        indicativePresentYo: 'hablo',
      ),
    ]);
    final dao = CatalogRawSearchDao(
        _EspWords(const []), _JpnWords(const []), conjugations);

    final hits =
        await dao.fetchConjugationSuggestions(const CatalogRawSearchQuery(
      catalogId: CatalogId.espJpnMain,
      text: 'hab',
      page: 0,
      size: 20,
    ));

    expect(conjugations.request, ('hab', 4, 0));
    expect(hits.single.matches, {'indicative_present_yo': 'hablo'});
  });
}

final class _EspWords implements IEsjWordLocalDataSource {
  _EspWords(this.rows);
  final List<EspJpnWordTableData> rows;
  (String, int, int, bool)? request;
  @override
  Future<List<EspJpnWordTableData>> getWordsByWord(String word) async => rows;
  @override
  Future<List<EspJpnWordTableData>> getWordsByWordByPage(
      String word, int size, int currentPage, bool forQuiz) async {
    request = (word, size, currentPage, forQuiz);
    return rows;
  }

  @override
  Future<List<EspJpnWordTableData>> getQuizWordsByWordByPage(
          String word, int size, int currentPage) async =>
      rows;
}

final class _JpnWords implements IJpnEspWordLocalDataSource {
  _JpnWords(this.rows);
  final List<JpnEspWordTableData> rows;
  (String, int, int)? request;
  @override
  Future<List<JpnEspWordTableData>> getWordsByWord(
      String word, int size, int currentPage) async {
    request = (word, size, currentPage);
    return rows;
  }
}

final class _Conjugations implements IConjugacionLocalDataSource {
  _Conjugations({this.suggestions = const []});
  final List<EspConjugationTableData> suggestions;
  (String, int, int)? request;
  @override
  Future<List<EspConjugationTableData>> getConjugacionByWordWithPage(
      String word, int size, int currentPage) async {
    request = (word, size, currentPage);
    return suggestions;
  }

  @override
  Future<List<EspConjugationTableData>> searchConjugationsAcrossCatalog(
          String word, int size, int currentPage) async =>
      const [];
  @override
  Future<EspConjugationTableData?> getConjugacionByWordId(int id) async => null;
  @override
  Future<bool> existsConjByWordId(int wordId) async => false;
  @override
  Future<String?> getSimpleMeaningById(int id) async => null;
  @override
  Future<Map<int, String>> getMeaningsByWordIds(List<int> wordIds) async =>
      const {};
}
