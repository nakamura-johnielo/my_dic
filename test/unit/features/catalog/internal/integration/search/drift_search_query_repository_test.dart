import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/conjugation/conjugation_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_dataset.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_word_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_dictionary_dataset.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_word_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/drift_search_query_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/search_query_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/search_ranking_lookup.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';
import 'package:my_dic/features/search/application/query/search_conjugation_match_key.dart';
import 'package:my_dic/features/search/application/query/search_direction.dart';
import 'package:my_dic/features/search/application/query/search_query.dart';

void main() {
  group('Catalog Search integration adapter', () {
    test('preserves primary order, pagination, suggestions, and enrichment',
        () async {
      final espWords = _EspJpnWords([
        EspJpnWordTableData(
          wordId: 2,
          word: 'hablar',
          partOfSpeech: CatalogPartOfSpeech.verb.wireValue,
        ),
        const EspJpnWordTableData(wordId: 1, word: 'haba'),
      ]);
      final conjugations = _Conjugations(
        suggestions: const [
          EspConjugationTableData(
            wordId: 3,
            word: 'hablo',
            indicativePresentYo: 'hablo',
          ),
        ],
        meanings: const {3: 'conjugation meaning'},
      );
      final dictionary = _EspJpnDictionary(
        contents: const {
          2: '<p data-orgtag="meaning">to <b>speak</b></p>',
          1: '<p data-orgtag="meaning">bean</p>',
          3: '<p data-orgtag="meaning">dictionary fallback</p>',
        },
        headwords: const {
          2: 'hablar<sup>(**)</sup>',
          1: 'haba',
          3: 'hablo<sup>(*)</sup>',
        },
      );
      final repository = _repository(
        espWords: espWords,
        conjugations: conjugations,
        espDictionary: dictionary,
        ranking: _Ranking(const {1: 10, 2: 20, 3: 30}),
      );

      final result = await repository.search(const SearchQuery(
        text: 'hab',
        direction: SearchDirection.espJpn,
        page: 0,
        size: 2,
        includeConjugationSuggestions: true,
      ));

      final page = result.dataOrNull!;
      expect(page.items.map((item) => item.wordId), [2, 1]);
      expect(page.items.first.hasConjugation, isTrue);
      expect(page.items.first.meaningText, 'to speak');
      expect(page.items.first.rankingNo, 20);
      expect(page.items.first.starCount, 2);
      expect(page.hasNext, isTrue);
      expect(espWords.arguments, ('hab', 2, 0, false));
      expect(conjugations.suggestionArguments, ('hab', 4, 0));
      expect(page.conjugationSuggestions, hasLength(1));
      expect(
        page.conjugationSuggestions.single
            .matches[SearchConjugationMatchKey.indicativePresentYo],
        'hablo',
      );
      expect(page.conjugationSuggestions.single.meaningText,
          'conjugation meaning');
      expect(page.conjugationSuggestions.single.starCount, 1);
      expect(page.issues, isEmpty);
    });

    test('requests zero-based later pages and suppresses suggestions',
        () async {
      final espWords = _EspJpnWords(const [
        EspJpnWordTableData(wordId: 7, word: 'later'),
      ]);
      final conjugations = _Conjugations();
      final repository = _repository(
        espWords: espWords,
        conjugations: conjugations,
      );

      final page = (await repository.search(const SearchQuery(
        text: 'la',
        direction: SearchDirection.espJpn,
        page: 2,
        size: 20,
        includeConjugationSuggestions: true,
      )))
          .dataOrNull!;

      expect(espWords.arguments, ('la', 20, 2, false));
      expect(conjugations.suggestionArguments, isNull);
      expect(page.conjugationSuggestions, isEmpty);
      expect(page.hasNext, isFalse);
    });

    test('preserves Jpn-Esp ordering and enriches only meanings', () async {
      final repository = _repository(
        jpnWords: _JpnEspWords(const [
          JpnEspWordTableData(wordId: 4, word: '話す'),
          JpnEspWordTableData(wordId: 8, word: '話'),
        ]),
        jpnDictionary: _JpnEspDictionary(contents: const {
          4: '<p data-orgtag="meaning">hablar</p>',
          8: '<p data-orgtag="meaning">historia</p>',
        }),
      );

      final page = (await repository.search(const SearchQuery(
        text: '話',
        direction: SearchDirection.jpnEsp,
        page: 0,
        size: 2,
        includeConjugationSuggestions: true,
      )))
          .dataOrNull!;

      expect(page.items.map((item) => item.wordId), [4, 8]);
      expect(
          page.items.map((item) => item.meaningText), ['hablar', 'historia']);
      expect(page.items.every((item) => item.rankingNo == null), isTrue);
      expect(page.items.every((item) => item.starCount == null), isTrue);
      expect(page.conjugationSuggestions, isEmpty);
      expect(page.hasNext, isTrue);
    });

    test('keeps primary results when enrichment sources partially fail',
        () async {
      final repository = _repository(
        espWords: _EspJpnWords(const [
          EspJpnWordTableData(wordId: 9, word: 'survivor'),
        ]),
        espDictionary: _EspJpnDictionary(throwOnBulk: true),
        ranking: _Ranking(const {}, throws: true),
      );

      final result = await repository.search(const SearchQuery(
        text: 'sur',
        direction: SearchDirection.espJpn,
        page: 0,
        size: 10,
        includeConjugationSuggestions: false,
      ));

      final page = result.dataOrNull!;
      expect(page.items.single.headword, 'survivor');
      expect(page.items.single.meaningText, isNull);
      expect(page.items.single.rankingNo, isNull);
      expect(page.items.single.starCount, isNull);
      expect(page.issues.map((issue) => issue.source).toSet(),
          {'ranking', 'meaning', 'starCount'});
    });

    test('wraps primary query failures as a failed repository result',
        () async {
      final repository = _repository(
        espWords: _EspJpnWords(const [], throws: true),
      );

      final result = await repository.search(const SearchQuery(
        text: 'x',
        direction: SearchDirection.espJpn,
        page: 0,
        size: 10,
        includeConjugationSuggestions: true,
      ));

      expect(result.isFailure, isTrue);
      expect(
          result.errorOrNull?.message, 'Unable to search dictionary entries.');
    });
  });
}

DriftSearchQueryRepository _repository({
  _EspJpnWords? espWords,
  _JpnEspWords? jpnWords,
  _Conjugations? conjugations,
  _EspJpnDictionary? espDictionary,
  _JpnEspDictionary? jpnDictionary,
  SearchRankingLookup? ranking,
}) {
  final conjugationSource = conjugations ?? _Conjugations();
  return DriftSearchQueryRepository(
    SearchQueryDao(
      espWords ?? _EspJpnWords(const []),
      jpnWords ?? _JpnEspWords(const []),
      conjugationSource,
    ),
    espDictionary ?? _EspJpnDictionary(),
    jpnDictionary ?? _JpnEspDictionary(),
    conjugationSource,
    ranking ?? _Ranking(const {}),
  );
}

final class _EspJpnWords implements IEsjWordLocalDataSource {
  _EspJpnWords(this.rows, {this.throws = false});
  final List<EspJpnWordTableData> rows;
  final bool throws;
  (String, int, int, bool)? arguments;

  @override
  Future<List<EspJpnWordTableData>> getWordsByWordByPage(
    String word,
    int size,
    int currentPage,
    bool forQuiz,
  ) async {
    arguments = (word, size, currentPage, forQuiz);
    if (throws) throw StateError('primary failed');
    return rows;
  }

  @override
  Future<List<EspJpnWordTableData>> getWordsByWord(String word) async => rows;
  @override
  Future<List<EspJpnWordTableData>> getQuizWordsByWordByPage(
          String word, int size, int currentPage) async =>
      rows;
}

final class _JpnEspWords implements IJpnEspWordLocalDataSource {
  _JpnEspWords(this.rows);
  final List<JpnEspWordTableData> rows;

  @override
  Future<List<JpnEspWordTableData>> getWordsByWord(
          String word, int size, int currentPage) async =>
      rows;
}

final class _Conjugations implements IConjugacionLocalDataSource {
  _Conjugations({this.suggestions = const [], this.meanings = const {}});
  final List<EspConjugationTableData> suggestions;
  final Map<int, String> meanings;
  (String, int, int)? suggestionArguments;

  @override
  Future<List<EspConjugationTableData>> getConjugacionByWordWithPage(
      String word, int size, int currentPage) async {
    suggestionArguments = (word, size, currentPage);
    return suggestions;
  }

  @override
  Future<Map<int, String>> getMeaningsByWordIds(List<int> wordIds) async =>
      meanings;
  @override
  Future<EspConjugationTableData?> getConjugacionByWordId(int id) async => null;
  @override
  Future<bool> existsConjByWordId(int wordId) async => false;
  @override
  Future<String?> getSimpleMeaningById(int id) async => null;
  @override
  Future<List<EspConjugationTableData>> searchConjugationsAcrossCatalog(
          String word, int size, int currentPage) async =>
      suggestions;
}

final class _EspJpnDictionary implements IEsjDictionaryLocalDataSource {
  _EspJpnDictionary({
    this.contents = const {},
    this.headwords = const {},
    this.throwOnBulk = false,
  });
  final Map<int, String> contents;
  final Map<int, String> headwords;
  final bool throwOnBulk;

  @override
  Future<Map<int, String>> getFirstContentsByWordIds(List<int> wordIds) async {
    if (throwOnBulk) throw StateError('contents failed');
    return contents;
  }

  @override
  Future<Map<int, String>> getFirstHeadwordsByWordIds(List<int> wordIds) async {
    if (throwOnBulk) throw StateError('headwords failed');
    return headwords;
  }

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
  Future<String?> getHeadwordById(int id) async => headwords[id];
  @override
  Future<String?> getSimpleMeaningById(int id) async => contents[id];
}

final class _JpnEspDictionary implements IJpnEspDictionaryLocalDataSource {
  _JpnEspDictionary({this.contents = const {}});
  final Map<int, String> contents;

  @override
  Future<Map<int, String>> getContentsByWordIds(List<int> wordIds) async =>
      contents;
  @override
  Future<List<JpnEspDictionaryDataSet>> getDictionaryByWordId(
          int wordId) async =>
      const [];
}

final class _Ranking implements SearchRankingLookup {
  _Ranking(this.values, {this.throws = false});
  final Map<int, int> values;
  final bool throws;

  @override
  Future<Map<int, int>> getRankingNosByWordIds(List<int> wordIds) async {
    if (throws) throw StateError('ranking failed');
    return values;
  }
}
