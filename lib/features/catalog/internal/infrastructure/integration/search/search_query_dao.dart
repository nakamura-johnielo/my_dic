import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/conjugation/conjugation_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_word_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_word_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_drift_mapper.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/search_result_conjugations.dart';
import 'package:my_dic/features/search/application/query/conjugation_search_item.dart';
import 'package:my_dic/features/search/application/query/search_conjugation_match_key.dart';
import 'package:my_dic/features/search/application/query/search_direction.dart';
import 'package:my_dic/features/search/application/query/search_catalog_word_ref.dart';
import 'package:my_dic/features/search/application/query/search_query.dart';

/// Catalog-owned adapter for the primary Search projection queries.
///
/// It returns Search-owned projection rows and never exposes Catalog internals.
class SearchQueryDao {
  SearchQueryDao(this._espJpnWords, this._jpnEspWords, this._conjugations);

  final IEsjWordLocalDataSource _espJpnWords;
  final IJpnEspWordLocalDataSource _jpnEspWords;
  final IConjugacionLocalDataSource _conjugations;

  Future<List<SearchPrimaryRow>> fetchPrimary(SearchQuery query) async {
    switch (query.direction) {
      case SearchDirection.espJpn:
        final rows = await _espJpnWords.getWordsByWordByPage(
          query.text,
          query.size,
          query.page,
          false,
        );
        return rows
            .map(CatalogDriftMapper.espJpnWord)
            .map(
              (word) => SearchPrimaryRow(
                wordId: word.wordId,
                word: query.direction.wordRef(word.wordId),
                headword: word.word,
                direction: SearchDirection.espJpn,
                hasConjugation: word.hasVerb(),
              ),
            )
            .toList(growable: false);
      case SearchDirection.jpnEsp:
        final rows = await _jpnEspWords.getWordsByWord(
          query.text,
          query.size,
          query.page,
        );
        return rows
            .map(CatalogDriftMapper.jpnEspWord)
            .map(
              (word) => SearchPrimaryRow(
                wordId: word.id,
                word: query.direction.wordRef(word.id),
                headword: word.word,
                direction: SearchDirection.jpnEsp,
                hasConjugation: false,
              ),
            )
            .toList(growable: false);
    }
  }

  Future<List<ConjugationSearchItem>> fetchConjugationSuggestions(
    SearchQuery query,
  ) async {
    if (query.direction != SearchDirection.espJpn ||
        !query.includeConjugationSuggestions ||
        query.page != 0) {
      return const [];
    }
    final rows = await _conjugations.getConjugacionByWordWithPage(
      query.text,
      4,
      0,
    );
    return rows
        .map(CatalogDriftMapper.conjugationSearchResult)
        .map(
          (item) => ConjugationSearchItem(
            wordId: item.wordId,
            word: SearchDirection.espJpn.wordRef(item.wordId),
            headword: item.word,
            matches: {
              for (final match in item.matches.entries)
                _toSearchMatchKey(match.key): match.value,
            },
            meaningText: null,
            rankingNo: null,
            starCount: null,
          ),
        )
        .toList(growable: false);
  }
}

SearchConjugationMatchKey _toSearchMatchKey(CatalogConjugationMatch match) {
  final moodTense = SearchMoodTense.values.byName(match.moodTense.name);
  final subject = match.subject == null
      ? null
      : SearchSubject.values.byName(match.subject!.name);
  return SearchConjugationMatchKey.values.firstWhere(
    (key) =>
        key.moodTense == moodTense &&
        (subject == null || key.subject == subject),
  );
}

class SearchPrimaryRow {
  const SearchPrimaryRow({
    required this.wordId,
    required this.word,
    required this.headword,
    required this.direction,
    required this.hasConjugation,
  });

  final int wordId;
  final CatalogWordRef word;
  final String headword;
  final SearchDirection direction;
  final bool hasConjugation;
}
