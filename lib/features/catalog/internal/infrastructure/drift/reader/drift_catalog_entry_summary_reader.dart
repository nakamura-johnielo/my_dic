import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_entry_summary_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_read_error_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/catalog_entry_summary_drift_query.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_search_models.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_entry_summary_reader_port.dart';

final class DriftCatalogEntrySummaryReader
    implements CatalogEntrySummaryReaderPort {
  DriftCatalogEntrySummaryReader(
    DatabaseProvider database, {
    CatalogEntrySummaryMapper mapper = const CatalogEntrySummaryMapper(),
    CatalogReadErrorMapper errorMapper = const CatalogReadErrorMapper(),
  })  : _query = CatalogEntrySummaryDriftQuery(database),
        _mapper = mapper,
        _errorMapper = errorMapper;

  final CatalogEntrySummaryDriftQuery _query;
  final CatalogEntrySummaryMapper _mapper;
  final CatalogReadErrorMapper _errorMapper;

  @override
  Future<Result<Map<CatalogWordRef, CatalogMeaningSummary>>> readMeanings(
    Iterable<CatalogWordRef> words,
  ) async {
    late final List<CatalogMeaningDriftRow> rows;
    try {
      rows = await _query.fetchMeanings(words);
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.query(cause, stackTrace));
    }

    late final Map<CatalogWordRef, CatalogMeaningSummary> result;
    try {
      result = {};
      for (final row in rows) {
        final meaning = _mapper.meaning(row);
        if (meaning != null) result[row.word] = meaning;
      }
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.conversion(cause, stackTrace));
    }
    try {
      return Result.success(result);
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.unexpected(cause, stackTrace));
    }
  }

  @override
  Future<Result<Map<CatalogWordRef, CatalogHeadwordMetadata>>>
      readHeadwordMetadata(Iterable<CatalogWordRef> words) async {
    late final List<CatalogHeadwordMetadataDriftRow> rows;
    try {
      rows = await _query.fetchHeadwordMetadata(words);
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.query(cause, stackTrace));
    }

    late final Map<CatalogWordRef, CatalogHeadwordMetadata> result;
    try {
      result = {for (final row in rows) row.word: _mapper.headword(row)};
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
