import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_drift_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_conjugation_match_mapper.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_search_models.dart';

final class CatalogSearchHitMapper {
  const CatalogSearchHitMapper();

  CatalogWordSearchHit espJpnWord(EspJpnWordTableData row) => _espJpnWord(row);

  CatalogWordSearchHit jpnEspWord(JpnEspWordTableData row) =>
      CatalogWordSearchHit(
        word: CatalogWordRef(
          catalogId: CatalogId.jpnEspMain,
          wordId: row.wordId,
        ),
        headword: row.word,
        hasConjugation: false,
      );

  CatalogConjugationSearchHit conjugation(
    EspConjugationTableData row, {
    required String searchText,
  }) {
    final matches = CatalogConjugationMatchMapper.fromRow(
      row,
      include: (form) => form.startsWith(searchText),
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
