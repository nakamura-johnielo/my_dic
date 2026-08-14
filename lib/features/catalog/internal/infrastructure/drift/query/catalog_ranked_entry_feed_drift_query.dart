import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';

final class CatalogRankedEntryFeedDriftRow {
  CatalogRankedEntryFeedDriftRow({
    required this.rankingId,
    required this.rankingNo,
    required this.rankedWord,
    required this.lemma,
    required this.wordId,
    required Iterable<CatalogPartOfSpeech> partsOfSpeech,
    required this.hasConjugation,
  }) : partsOfSpeech = Set.unmodifiable(partsOfSpeech);

  final int rankingId;
  final int rankingNo;
  final String rankedWord;
  final String lemma;
  final int wordId;
  final Set<CatalogPartOfSpeech> partsOfSpeech;
  final bool hasConjugation;
}

/// Catalog-owned deterministic ranking source query.
final class CatalogRankedEntryFeedDriftQuery {
  const CatalogRankedEntryFeedDriftQuery(this._database);

  final DatabaseProvider _database;

  Future<List<CatalogRankedEntryFeedDriftRow>> fetch({
    required int offset,
    required int limit,
  }) async {
    final rows = await _database.customSelect(
      '''
        SELECT
          r.ranking_id AS ranking_id,
          r.ranking_no AS ranking_no,
          r.word AS ranked_word,
          r.word_origin AS lemma,
          r.word_id AS word_id,
          CASE WHEN EXISTS (
            SELECT 1 FROM conjugations c WHERE c.word_id = r.word_id
          ) THEN 1 ELSE 0 END AS has_conjugation
        FROM rankings r
        WHERE r.ranking_id IS NOT NULL
          AND r.ranking_no IS NOT NULL
          AND r.word IS NOT NULL
          AND r.word_origin IS NOT NULL
          AND r.word_id IS NOT NULL
        ORDER BY r.ranking_no, r.ranking_id
        LIMIT ? OFFSET ?
      ''',
      variables: [Variable.withInt(limit), Variable.withInt(offset)],
    ).get();
    if (rows.isEmpty) return const [];

    final wordIds = rows
        .map((row) => row.read<int>('word_id'))
        .toSet()
        .toList(growable: false);
    final partsByWord = await _readPartsOfSpeech(wordIds);
    return rows
        .map(
          (row) => CatalogRankedEntryFeedDriftRow(
            rankingId: row.read<int>('ranking_id'),
            rankingNo: row.read<int>('ranking_no'),
            rankedWord: row.read<String>('ranked_word'),
            lemma: row.read<String>('lemma'),
            wordId: row.read<int>('word_id'),
            partsOfSpeech:
                partsByWord[row.read<int>('word_id')] ?? const {},
            hasConjugation: row.read<int>('has_conjugation') == 1,
          ),
        )
        .toList(growable: false);
  }

  Future<Map<int, Set<CatalogPartOfSpeech>>> _readPartsOfSpeech(
    List<int> wordIds,
  ) async {
    if (wordIds.isEmpty) return const {};
    final placeholders = List.filled(wordIds.length, '?').join(', ');
    final rows = await _database.customSelect(
      '''
        SELECT word_id, part_of_speech
        FROM part_of_speech_lists
        WHERE word_id IN ($placeholders)
        ORDER BY part_of_speech_id
      ''',
      variables: wordIds.map(Variable.withInt).toList(growable: false),
    ).get();
    final result = <int, Set<CatalogPartOfSpeech>>{};
    for (final row in rows) {
      final wordId = row.read<int>('word_id');
      (result[wordId] ??= <CatalogPartOfSpeech>{}).add(
        CatalogPartOfSpeech.fromWireValue(row.read<String>('part_of_speech')),
      );
    }
    return result;
  }
}
