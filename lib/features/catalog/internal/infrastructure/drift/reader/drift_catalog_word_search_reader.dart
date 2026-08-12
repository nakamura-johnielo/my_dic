import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_read_error_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_search_hit_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/catalog_word_search_drift_query.dart';
import 'package:my_dic/features/catalog/port/model/catalog_search_models.dart';
import 'package:my_dic/features/catalog/port/query/catalog_word_search_query.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_word_search_reader_port.dart';
import 'package:my_dic/features/catalog/port/result/catalog_search_page.dart';

final class DriftCatalogWordSearchReader
    implements CatalogWordSearchReaderPort {
  DriftCatalogWordSearchReader(
    DatabaseProvider database, {
    CatalogSearchHitMapper mapper = const CatalogSearchHitMapper(),
    CatalogReadErrorMapper errorMapper = const CatalogReadErrorMapper(),
  })  : _query = CatalogWordSearchDriftQuery(database),
        _mapper = mapper,
        _errorMapper = errorMapper;

  const DriftCatalogWordSearchReader.withQuery(
    this._query, {
    CatalogSearchHitMapper mapper = const CatalogSearchHitMapper(),
    CatalogReadErrorMapper errorMapper = const CatalogReadErrorMapper(),
  })  : _mapper = mapper,
        _errorMapper = errorMapper;

  final CatalogWordSearchDriftQuery _query;
  final CatalogSearchHitMapper _mapper;
  final CatalogReadErrorMapper _errorMapper;

  @override
  Future<Result<CatalogSearchPage<CatalogWordSearchHit>>> searchWords(
    CatalogWordSearchQuery query,
  ) async {
    late final List<CatalogWordSearchDriftRow> rows;
    try {
      rows = await _query.fetch(query);
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.query(cause, stackTrace));
    }

    late final List<CatalogWordSearchHit> items;
    try {
      items = rows.take(query.size).map(_mapper.word).toList(growable: false);
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
}
