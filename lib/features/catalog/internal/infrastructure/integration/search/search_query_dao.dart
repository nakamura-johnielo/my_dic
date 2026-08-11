import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/conjugation/conjugation_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_word_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_word_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_drift_mapper.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/search_result_conjugations.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/catalog/port/raw_search_reader.dart';

// TODO refactor repository的立ち位置
/// Catalog-owned Drift queries behind the raw Search reader.
final class CatalogRawSearchDao {
  CatalogRawSearchDao(this._espJpnWords, this._jpnEspWords, this._conjugations);

  final IEsjWordLocalDataSource _espJpnWords;
  final IJpnEspWordLocalDataSource _jpnEspWords;
  final IConjugacionLocalDataSource _conjugations;

  Future<List<CatalogPrimaryRawHit>> fetchPrimary(
    CatalogRawSearchQuery query,
  ) async {
    switch (query.catalogId) {
      case CatalogId.espJpnMain:
        final rows = await _espJpnWords.getWordsByWordByPage(
          query.text,
          query.size,
          query.page,
          false,
        );
        return rows
            .map(CatalogDriftMapper.espJpnWord)
            .map(
              (word) => CatalogPrimaryRawHit(
                word: CatalogWordRef(
                  catalogId: CatalogId.espJpnMain,
                  wordId: word.wordId,
                ),
                headword: word.word,
                hasConjugation: word.hasVerb(),
              ),
            )
            .toList(growable: false);
      case CatalogId.jpnEspMain:
        final rows = await _jpnEspWords.getWordsByWord(
          query.text,
          query.size,
          query.page,
        );
        return rows
            .map(CatalogDriftMapper.jpnEspWord)
            .map(
              (word) => CatalogPrimaryRawHit(
                word: CatalogWordRef(
                  catalogId: CatalogId.jpnEspMain,
                  wordId: word.id,
                ),
                headword: word.word,
                hasConjugation: false,
              ),
            )
            .toList(growable: false);
    }
  }

  Future<List<CatalogConjugationRawHit>> fetchConjugationSuggestions(
    CatalogRawSearchQuery query,
  ) async {
    if (query.catalogId != CatalogId.espJpnMain || query.page != 0) {
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
          (item) => CatalogConjugationRawHit(
            word: CatalogWordRef(
              catalogId: CatalogId.espJpnMain,
              wordId: item.wordId,
            ),
            headword: item.word,
            matches: {
              for (final match in item.matches.entries)
                _toWireMatchKey(match.key): match.value,
            },
          ),
        )
        .toList(growable: false);
  }
}

String _toWireMatchKey(CatalogConjugationMatch match) {
  final moodTense = switch (match.moodTense) {
    CatalogMoodTense.participlePresent => 'present_participle',
    CatalogMoodTense.participlePast => 'past_participle',
    CatalogMoodTense.indicativePresent => 'indicative_present',
    CatalogMoodTense.indicativePreterite => 'indicative_preterite',
    CatalogMoodTense.indicativeImperfect => 'indicative_imperfect',
    CatalogMoodTense.indicativeFuture => 'indicative_future',
    CatalogMoodTense.indicativeConditional => 'indicative_conditional',
    CatalogMoodTense.imperative => 'imperative',
    CatalogMoodTense.subjunctivePresent => 'subjunctive_present',
    CatalogMoodTense.subjunctivePast => 'subjunctive_past',
  };
  return match.subject == null
      ? moodTense
      : '${moodTense}_${match.subject!.name}';
}
