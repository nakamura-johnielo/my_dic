import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_entry_summary_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_read_error_mapper.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_search_models.dart';
import 'package:my_dic/features/catalog/port/queryport/catalog_ranking_reader_port.dart';

final class DriftCatalogRankingQueryService implements CatalogRankingQueryPort {
  DriftCatalogRankingQueryService(
    DatabaseProvider database, {
    CatalogEntrySummaryMapper mapper = const CatalogEntrySummaryMapper(),
    CatalogReadErrorMapper errorMapper = const CatalogReadErrorMapper(),
  })  : _database = database,
        _mapper = mapper,
        _errorMapper = errorMapper;

  final DatabaseProvider _database;
  final CatalogEntrySummaryMapper _mapper;
  final CatalogReadErrorMapper _errorMapper;

  @override
  Future<Result<Map<CatalogWordRef, CatalogRankingMetadata>>>
      readRankingMetadata(Iterable<CatalogWordRef> words) async {
    late final Map<CatalogWordRef, int> rows;
    try {
      rows = await _fetch(words);
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.query(cause, stackTrace));
    }

    late final Map<CatalogWordRef, CatalogRankingMetadata> result;
    try {
      result = {
        for (final entry in rows.entries)
          entry.key: _mapper.ranking(entry.value),
      };
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.conversion(cause, stackTrace));
    }
    try {
      return Result.success(result);
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.unexpected(cause, stackTrace));
    }
  }

  Future<Map<CatalogWordRef, int>> _fetch(
    Iterable<CatalogWordRef> words,
  ) async {
    final refs = <int, CatalogWordRef>{};
    for (final word in words) {
      if (word.catalogId == CatalogId.espJpnMain) {
        refs.putIfAbsent(word.wordId, () => word);
      }
    }
    if (refs.isEmpty) return const {};
    final variables = refs.keys.map(Variable.withInt).toList(growable: false);
    final placeholders = List.filled(variables.length, '?').join(', ');
    final rows = await _database.customSelect(
      '''
        SELECT word_id, MIN(ranking_no) AS ranking_no
        FROM rankings
        WHERE word_id IN ($placeholders)
        GROUP BY word_id
      ''',
      variables: variables,
    ).get();
    final result = <CatalogWordRef, int>{};
    for (final row in rows) {
      final wordId = row.read<int?>('word_id');
      final rankingNo = row.read<int?>('ranking_no');
      if (wordId != null && rankingNo != null) {
        result[refs[wordId]!] = rankingNo;
      }
    }
    return result;
  }
}
