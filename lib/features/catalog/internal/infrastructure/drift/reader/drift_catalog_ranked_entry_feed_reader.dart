import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_ranked_entry_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_read_error_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/catalog_ranked_entry_feed_drift_query.dart';
import 'package:my_dic/features/catalog/port/query/catalog_ranked_entry_feed_query.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_ranked_entry_feed_reader_port.dart';
import 'package:my_dic/features/catalog/port/result/catalog_ranked_entry_feed.dart';

typedef CatalogRankedEntryFeedFetch =
    Future<List<CatalogRankedEntryFeedDriftRow>> Function({
  required int offset,
  required int limit,
});

final class DriftCatalogRankedEntryFeedQueryService
    implements CatalogRankedEntryFeedQueryPort {
  DriftCatalogRankedEntryFeedQueryService(
    DatabaseProvider database, {
    CatalogRankedEntryFeedFetch? fetch,
    CatalogRankedEntryMapper mapper = const CatalogRankedEntryMapper(),
    CatalogReadErrorMapper errorMapper = const CatalogReadErrorMapper(),
  })  : _fetch = fetch ?? CatalogRankedEntryFeedDriftQuery(database).fetch,
        _mapper = mapper,
        _errorMapper = errorMapper;

  final CatalogRankedEntryFeedFetch _fetch;
  final CatalogRankedEntryMapper _mapper;
  final CatalogReadErrorMapper _errorMapper;

  @override
  Future<Result<CatalogRankedEntryFeed>> readRankedEntries(
    CatalogRankedEntryFeedQuery query,
  ) async {
    late final List<CatalogRankedEntryFeedDriftRow> rows;
    try {
      rows = await _fetch(offset: query.offset, limit: query.size + 1);
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.query(cause, stackTrace));
    }

    try {
      final hasMore = rows.length > query.size;
      final items = rows.take(query.size).map(_mapper.map);
      return Result.success(
        CatalogRankedEntryFeed(items: items, hasMore: hasMore),
      );
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.conversion(cause, stackTrace));
    }
  }
}
