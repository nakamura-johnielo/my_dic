import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/internal/infrastructure/drift/ranking_dao.dart';
import 'package:my_dic/features/ranking/port/model/ranking_list_item.dart';
import 'package:my_dic/features/ranking/port/model/ranking_page.dart';
import 'package:my_dic/features/ranking/port/model/ranking_query.dart';
import 'package:my_dic/features/ranking/port/ranking_query_repository.dart';

/// Drift-backed implementation of the ranking screen read port.
class DriftRankingQueryRepository implements IRankingQueryRepository {
  DriftRankingQueryRepository(this._dao);

  final RankingDao _dao;

  @override
  Future<Result<RankingPage>> fetchPage(RankingQuery query) async {
    try {
      final rows = await _dao.fetchRankingQueryPage(query);
      // The DAO filters invalid rows before pagination. Keeping the look-ahead
      // calculation on its returned page also preserves offset semantics if a
      // future projection change unexpectedly lets an invalid row through.
      final hasNext = rows.length > query.size;
      final visibleRows = hasNext ? rows.take(query.size) : rows;
      final validRows = visibleRows
          .where((row) =>
              row.rank != null &&
              row.rankingId != null &&
              row.rankedWord != null &&
              row.lemma != null &&
              row.wordId != null)
          .toList(growable: false);
      final skippedCount = visibleRows.length - validRows.length;
      if (skippedCount > 0) {
        AppLogger.event(
          'ranking_invalid_rows_skipped',
          context: {
            'skippedCount': skippedCount,
            'page': query.page,
            'pageSize': query.size,
          },
        );
      }

      final items = <RankingListItem>[];
      for (final row in validRows) {
        items.add(RankingListItem(
          rankingId: row.rankingId!,
          rank: row.rank!,
          rankedWord: row.rankedWord!,
          lemma: row.lemma!,
          wordId: row.wordId!,
          hasConjugation: row.hasConjugation,
        ));
      }
      return Result.success(RankingPage(items: items, hasNext: hasNext));
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'Failed to fetch ranking projection.',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }
}
