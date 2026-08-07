import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

/// Search-owned ranking enrichment lookup.
///
/// This deliberately exposes only the bulk data Search needs; it does not
/// reintroduce a dependency on Ranking's screen projection or data source.
class SearchRankingLookup {
  SearchRankingLookup(this._database);

  final DatabaseProvider _database;

  Future<Map<int, int>> getRankingNosByWordIds(List<int> wordIds) async {
    if (wordIds.isEmpty) return const {};
    final variables = wordIds.map(Variable.withInt).toList(growable: false);
    final placeholders = List.filled(wordIds.length, '?').join(', ');
    final rows = await _database.customSelect(
      '''
        SELECT r.word_id, r.ranking_no
        FROM rankings r
        WHERE r.word_id IN ($placeholders)
          AND r.ranking_id = (
            SELECT MIN(r2.ranking_id)
            FROM rankings r2
            WHERE r2.word_id = r.word_id
          )
      ''',
      variables: variables,
    ).get();
    return {
      for (final row in rows)
        if (row.read<int?>('word_id') case final wordId?)
          wordId: row.read<int>('ranking_no'),
    };
  }
}
