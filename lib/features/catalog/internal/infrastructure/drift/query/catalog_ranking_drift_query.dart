import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

final class CatalogRankingDriftRow {
  const CatalogRankingDriftRow({
    required this.word,
    required this.rankingNo,
  });

  final CatalogWordRef word;
  final int rankingNo;
}

/// Catalog-owned operation for the representative ranking of each word.
final class CatalogRankingDriftQuery {
  const CatalogRankingDriftQuery(this._database);

  final DatabaseProvider _database;

  Future<List<CatalogRankingDriftRow>> fetch(
    Iterable<CatalogWordRef> words,
  ) async {
    final refs = <int, CatalogWordRef>{};
    for (final word in words) {
      if (word.catalogId == CatalogId.espJpnMain) {
        refs.putIfAbsent(word.wordId, () => word);
      }
    }
    if (refs.isEmpty) return const [];

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
    final results = <CatalogRankingDriftRow>[];
    for (final row in rows) {
      final wordId = row.read<int?>('word_id');
      final rankingNo = row.read<int?>('ranking_no');
      if (wordId == null || rankingNo == null) continue;
      results.add(CatalogRankingDriftRow(
        word: refs[wordId]!,
        rankingNo: rankingNo,
      ));
    }
    return results;
  }
}
