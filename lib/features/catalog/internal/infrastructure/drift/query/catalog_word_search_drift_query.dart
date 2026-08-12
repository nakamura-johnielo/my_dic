import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/query/catalog_word_search_query.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/catalog_like_pattern.dart';

sealed class CatalogWordSearchDriftRow {
  const CatalogWordSearchDriftRow();
}

final class EspJpnWordSearchDriftRow extends CatalogWordSearchDriftRow {
  const EspJpnWordSearchDriftRow(this.row);

  final EspJpnWordTableData row;
}

final class JpnEspWordSearchDriftRow extends CatalogWordSearchDriftRow {
  const JpnEspWordSearchDriftRow(this.row);

  final JpnEspWordTableData row;
}

/// Catalog-owned primary-word query. Paging is expressed in row units so the
/// look-ahead limit never changes the page offset.
final class CatalogWordSearchDriftQuery {
  const CatalogWordSearchDriftQuery(this._database);

  final DatabaseProvider _database;

  Future<List<CatalogWordSearchDriftRow>> fetch(
    CatalogWordSearchQuery query,
  ) async {
    final limit = query.size + 1;
    final offset = query.size * query.page;
    final pattern = catalogPrefixLikePattern(query.text);
    switch (query.catalogId) {
      case CatalogId.espJpnMain:
        final rows = await (_database.select(_database.espJpnWords)
              ..where((table) => table.word.like(
                    pattern,
                    escapeChar: catalogLikeEscapeCharacter,
                  ))
              ..limit(limit, offset: offset))
            .get();
        return rows.map(EspJpnWordSearchDriftRow.new).toList(growable: false);
      case CatalogId.jpnEspMain:
        final rows = await (_database.select(_database.jpnEspWords)
              ..where((table) => table.word.like(
                    pattern,
                    escapeChar: catalogLikeEscapeCharacter,
                  ))
              ..limit(limit, offset: offset))
            .get();
        return rows.map(JpnEspWordSearchDriftRow.new).toList(growable: false);
    }
  }
}
