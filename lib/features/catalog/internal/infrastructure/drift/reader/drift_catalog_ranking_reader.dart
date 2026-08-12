import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_entry_summary_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_read_error_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/catalog_ranking_drift_query.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_search_models.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_ranking_reader_port.dart';

final class DriftCatalogRankingReader implements CatalogRankingReaderPort {
  DriftCatalogRankingReader(
    DatabaseProvider database, {
    CatalogEntrySummaryMapper mapper = const CatalogEntrySummaryMapper(),
    CatalogReadErrorMapper errorMapper = const CatalogReadErrorMapper(),
  })  : _query = CatalogRankingDriftQuery(database),
        _mapper = mapper,
        _errorMapper = errorMapper;

  final CatalogRankingDriftQuery _query;
  final CatalogEntrySummaryMapper _mapper;
  final CatalogReadErrorMapper _errorMapper;

  @override
  Future<Result<Map<CatalogWordRef, CatalogRankingMetadata>>>
      readRankingMetadata(Iterable<CatalogWordRef> words) async {
    late final List<CatalogRankingDriftRow> rows;
    try {
      rows = await _query.fetch(words);
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.query(cause, stackTrace));
    }

    late final Map<CatalogWordRef, CatalogRankingMetadata> result;
    try {
      result = {for (final row in rows) row.word: _mapper.ranking(row)};
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.conversion(cause, stackTrace));
    }
    try {
      return Result.success(result);
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.unexpected(cause, stackTrace));
    }
  }
}
