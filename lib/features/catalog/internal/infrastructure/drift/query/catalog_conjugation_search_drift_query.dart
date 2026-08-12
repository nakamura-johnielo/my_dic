import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/port/query/catalog_conjugation_search_query.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/catalog_like_pattern.dart';

final class CatalogConjugationSearchDriftRow {
  const CatalogConjugationSearchDriftRow({
    required this.row,
    required this.searchText,
  });

  final EspConjugationTableData row;
  final String searchText;
}

/// Catalog-owned conjugation query with exact matches ordered before prefixes.
final class CatalogConjugationSearchDriftQuery {
  const CatalogConjugationSearchDriftQuery(this._database);

  final DatabaseProvider _database;

  Future<List<CatalogConjugationSearchDriftRow>> fetch(
    CatalogConjugationSearchQuery query,
  ) async {
    final limit = query.size + 1;
    final offset = query.size * query.page;
    final pattern = catalogPrefixLikePattern(query.text);
    final statement = _database.select(_database.espConjugations)
      ..where((table) =>
          table.word.like(pattern, escapeChar: catalogLikeEscapeCharacter) |
          _forms(table)
              .map((column) => column.like(
                    pattern,
                    escapeChar: catalogLikeEscapeCharacter,
                  ))
              .reduce((left, right) => left | right))
      ..orderBy([
        (table) => OrderingTerm.desc(table.word.equals(query.text) |
            _forms(table)
                .map((column) => column.equals(query.text))
                .reduce((left, right) => left | right)),
        (table) => OrderingTerm.asc(table.wordId),
      ])
      ..limit(limit, offset: offset);
    final rows = await statement.get();
    return rows
        .map((row) => CatalogConjugationSearchDriftRow(
              row: row,
              searchText: query.text,
            ))
        .toList(growable: false);
  }
}

List<GeneratedColumn<String>> _forms($EspConjugationsTable table) => [
      table.presentParticiple,
      table.pastParticiple,
      table.indicativePresentYo,
      table.indicativePresentTu,
      table.indicativePresentEl,
      table.indicativePresentNosotros,
      table.indicativePresentVosotros,
      table.indicativePresentEllos,
      table.indicativePreteriteYo,
      table.indicativePreteriteTu,
      table.indicativePreteriteEl,
      table.indicativePreteriteNosotros,
      table.indicativePreteriteVosotros,
      table.indicativePreteriteEllos,
      table.indicativeImperfectYo,
      table.indicativeImperfectTu,
      table.indicativeImperfectEl,
      table.indicativeImperfectNosotros,
      table.indicativeImperfectVosotros,
      table.indicativeImperfectEllos,
      table.indicativeFutureYo,
      table.indicativeFutureTu,
      table.indicativeFutureEl,
      table.indicativeFutureNosotros,
      table.indicativeFutureVosotros,
      table.indicativeFutureEllos,
      table.indicativeConditionalYo,
      table.indicativeConditionalTu,
      table.indicativeConditionalEl,
      table.indicativeConditionalNosotros,
      table.indicativeConditionalVosotros,
      table.indicativeConditionalEllos,
      table.imperativeTu,
      table.imperativeEl,
      table.imperativeNosotros,
      table.imperativeVosotros,
      table.imperativeEllos,
      table.subjunctivePresentYo,
      table.subjunctivePresentTu,
      table.subjunctivePresentEl,
      table.subjunctivePresentNosotros,
      table.subjunctivePresentVosotros,
      table.subjunctivePresentEllos,
      table.subjunctivePastYo,
      table.subjunctivePastTu,
      table.subjunctivePastEl,
      table.subjunctivePastNosotros,
      table.subjunctivePastVosotros,
      table.subjunctivePastEllos,
    ];
