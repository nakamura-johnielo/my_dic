import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_drift_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_conjugation_match_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/catalog_conjugation_search_drift_query.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/catalog_word_search_drift_query.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_search_models.dart';

final class CatalogSearchHitMapper {
  const CatalogSearchHitMapper();

  CatalogWordSearchHit word(CatalogWordSearchDriftRow source) =>
      switch (source) {
        EspJpnWordSearchDriftRow(:final row) => _espJpnWord(row),
        JpnEspWordSearchDriftRow(:final row) => CatalogWordSearchHit(
            word: CatalogWordRef(
              catalogId: CatalogId.jpnEspMain,
              wordId: row.wordId,
            ),
            headword: row.word,
            hasConjugation: false,
          ),
      };

  CatalogConjugationSearchHit conjugation(
    CatalogConjugationSearchDriftRow source,
  ) {
    final row = source.row;
    final matches = CatalogConjugationMatchMapper.fromRow(
      row,
      include: (form) => form.startsWith(source.searchText),
    );
    return CatalogConjugationSearchHit(
      word: CatalogWordRef(
        catalogId: CatalogId.espJpnMain,
        wordId: row.wordId,
      ),
      headword: row.word,
      matches: matches,
    );
  }
}

CatalogWordSearchHit _espJpnWord(EspJpnWordTableData row) {
  final word = CatalogDriftMapper.espJpnWord(row);
  return CatalogWordSearchHit(
    word: CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: word.wordId,
    ),
    headword: word.word,
    hasConjugation: word.hasVerb(),
  );
}
