import 'package:my_dic/core/infrastructure/datasource/conjugacion/i_conjugacion_local_datasource.dart';
import 'package:my_dic/core/infrastructure/datasource/esj/i_esj_word_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp/i_jpn_esp_word_data_source.dart';
import 'package:my_dic/core/infrastructure/repositories/converters/conjugacion_converter.dart';
import 'package:my_dic/core/infrastructure/repositories/converters/esj_word_converter.dart';
import 'package:my_dic/core/infrastructure/repositories/converters/jpn_esp_word_converter.dart';
import 'package:my_dic/features/search/application/query/conjugation_search_item.dart';
import 'package:my_dic/features/search/application/query/search_direction.dart';
import 'package:my_dic/features/search/application/query/search_query.dart';

/// Feature-owned adapter for the primary Search projection queries.
///
/// It deliberately returns feature-private rows rather than Drift rows.
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
            .map(EsjWordConverter.toEntity)
            .map(
              (word) => SearchPrimaryRow(
                wordId: word.wordId,
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
            .map(JpnEspWordConverter.toEntity)
            .map(
              (word) => SearchPrimaryRow(
                wordId: word.id,
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
        .map(ConjugacionConverter.toSearchResult)
        .map(
          (item) => ConjugationSearchItem(
            wordId: item.wordId,
            headword: item.word,
            matches: item.matches,
            meaningText: null,
            rankingNo: null,
            starCount: null,
          ),
        )
        .toList(growable: false);
  }

  /// Paged conjugation lookup used by Quiz, represented by Search query data.
  Future<List<ConjugationSearchItem>> fetchQuizItems(SearchQuery query) async {
    if (query.direction != SearchDirection.espJpn) return const [];
    final rows = await _conjugations.getQuizConjugacionByWordWithPage(
      query.text,
      query.size,
      query.page,
    );
    return rows
        .map(ConjugacionConverter.toSearchResult)
        .map(
          (item) => ConjugationSearchItem(
            wordId: item.wordId,
            headword: item.word,
            matches: item.matches,
            meaningText: null,
            rankingNo: null,
            starCount: null,
          ),
        )
        .toList(growable: false);
  }
}

class SearchPrimaryRow {
  const SearchPrimaryRow({
    required this.wordId,
    required this.headword,
    required this.direction,
    required this.hasConjugation,
  });

  final int wordId;
  final String headword;
  final SearchDirection direction;
  final bool hasConjugation;
}
