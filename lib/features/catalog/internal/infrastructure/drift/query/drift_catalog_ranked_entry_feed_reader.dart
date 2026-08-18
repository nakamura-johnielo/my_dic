import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_ranked_entry_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_read_error_mapper.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';
import 'package:my_dic/features/catalog/port/model/catalog_ranked_entry.dart';
import 'package:my_dic/features/catalog/port/inputdata/catalog_ranked_entry_feed_query.dart';
import 'package:my_dic/features/catalog/port/queryport/catalog_ranked_entry_feed_reader_port.dart';
import 'package:my_dic/features/catalog/port/result/catalog_ranked_entry_feed.dart';

typedef CatalogRankedEntryFeedFetch = Future<List<CatalogRankedEntry>>
    Function({
  required int offset,
  required int limit,
});

final class DriftCatalogRankedEntryFeedQueryService
    implements CatalogRankedEntryFeedQueryPort {
  DriftCatalogRankedEntryFeedQueryService(
    this._database, {
    CatalogRankedEntryFeedFetch? fetch,
    CatalogRankedEntryMapper mapper = const CatalogRankedEntryMapper(),
    CatalogReadErrorMapper errorMapper = const CatalogReadErrorMapper(),
  })  : _fetchOverride = fetch,
        _mapper = mapper,
        _errorMapper = errorMapper;

  final DatabaseProvider _database;
  final CatalogRankedEntryFeedFetch? _fetchOverride;
  final CatalogRankedEntryMapper _mapper;
  final CatalogReadErrorMapper _errorMapper;

  @override
  Future<Result<CatalogRankedEntryFeed>> readRankedEntries(
    CatalogRankedEntryFeedQuery query,
  ) async {
    late final List<CatalogRankedEntry> items;
    try {
      items = await (_fetchOverride ?? _fetch)(
        offset: query.offset,
        limit: query.size + 1,
      );
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.query(cause, stackTrace));
    }

    try {
      return Result.success(CatalogRankedEntryFeed(
        items: items.take(query.size),
        hasMore: items.length > query.size,
      ));
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.conversion(cause, stackTrace));
    }
  }

  Future<List<CatalogRankedEntry>> _fetch({
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
    return rows.map((row) {
      final wordId = row.read<int>('word_id');
      return _mapper.map(
        rankingId: row.read<int>('ranking_id'),
        rankingNo: row.read<int>('ranking_no'),
        rankedWord: row.read<String>('ranked_word'),
        lemma: row.read<String>('lemma'),
        wordId: wordId,
        partsOfSpeech: partsByWord[wordId] ?? const {},
        hasConjugation: row.read<int>('has_conjugation') == 1,
      );
    }).toList(growable: false);
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
        CatalogPartOfSpeech.fromWireValue(
          row.readNullable<String>('part_of_speech'),
        ),
      );
    }
    return result;
  }
}
