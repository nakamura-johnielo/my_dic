import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_read_error_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_search_hit_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/catalog_like_pattern.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/model/catalog_search_models.dart';
import 'package:my_dic/features/catalog/port/inputdata/catalog_word_search_query.dart';
import 'package:my_dic/features/catalog/port/queryport/catalog_word_search_reader_port.dart';
import 'package:my_dic/features/catalog/port/result/catalog_search_page.dart';

final class DriftCatalogWordSearchQueryService
    implements CatalogWordSearchQueryPort {
  DriftCatalogWordSearchQueryService(
    DatabaseProvider database, {
    CatalogSearchHitMapper mapper = const CatalogSearchHitMapper(),
    CatalogReadErrorMapper errorMapper = const CatalogReadErrorMapper(),
  })  : _database = database,
        _mapper = mapper,
        _errorMapper = errorMapper;

  final DatabaseProvider _database;
  final CatalogSearchHitMapper _mapper;
  final CatalogReadErrorMapper _errorMapper;

  @override
  Future<Result<CatalogSearchPage<CatalogWordSearchHit>>> searchWords(
    CatalogWordSearchQuery query,
  ) async {
    late final List<CatalogWordSearchHit> rows;
    try {
      rows = await _fetch(query);
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.query(cause, stackTrace));
    }

    late final List<CatalogWordSearchHit> items;
    try {
      items = rows.take(query.size).toList(growable: false);
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.conversion(cause, stackTrace));
    }

    try {
      return Result.success(CatalogSearchPage(
        items: items,
        hasMore: rows.length > query.size,
      ));
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.unexpected(cause, stackTrace));
    }
  }

  Future<List<CatalogWordSearchHit>> _fetch(
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
        return rows.map(_mapper.espJpnWord).toList(growable: false);
      case CatalogId.jpnEspMain:
        final rows = await (_database.select(_database.jpnEspWords)
              ..where((table) => table.word.like(
                    pattern,
                    escapeChar: catalogLikeEscapeCharacter,
                  ))
              ..limit(limit, offset: offset))
            .get();
        return rows.map(_mapper.jpnEspWord).toList(growable: false);
    }
  }
}
