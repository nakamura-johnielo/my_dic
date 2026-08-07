import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/application/query/i_ranking_query_repository.dart';
import 'package:my_dic/features/ranking/application/query/ranking_list_item.dart';
import 'package:my_dic/features/ranking/application/query/ranking_page.dart';
import 'package:my_dic/features/ranking/application/query/ranking_query.dart';
import 'package:my_dic/features/ranking/data/data_source/local/ranking_dao.dart';

/// Drift-backed implementation of the ranking screen read port.
class DriftRankingQueryRepository implements IRankingQueryRepository {
  DriftRankingQueryRepository(this._dao);

  final RankingDao _dao;

  @override
  Future<Result<RankingPage>> fetchPage(RankingQuery query) async {
    try {
      final rows = await _dao.fetchRankingQueryPage(query);
      final hasNext = rows.length > query.size;
      final visibleRows = hasNext ? rows.take(query.size) : rows;
      final items = <RankingListItem>[];
      for (final row in visibleRows) {
        final rank = row.rank;
        final rankedWord = row.rankedWord;
        final lemma = row.lemma;
        final wordId = row.wordId;
        if (rank == null ||
            rankedWord == null ||
            lemma == null ||
            wordId == null) {
          return Result.failure(DatabaseError(
            message: 'Ranking projection contains a required null value.',
          ));
        }
        items.add(RankingListItem(
          rank: rank,
          rankedWord: rankedWord,
          lemma: lemma,
          wordId: wordId,
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
