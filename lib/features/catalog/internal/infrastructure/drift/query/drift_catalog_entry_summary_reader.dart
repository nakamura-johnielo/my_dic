import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_entry_summary_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_read_error_mapper.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_search_models.dart';
import 'package:my_dic/features/catalog/port/queryport/catalog_entry_summary_reader_port.dart';

typedef _MeaningRow = ({
  CatalogWordRef word,
  String html,
  bool isConjugation,
});
typedef _HeadwordRow = ({CatalogWordRef word, String html});

final class DriftCatalogEntrySummaryQueryService
    implements CatalogEntrySummaryQueryPort {
  DriftCatalogEntrySummaryQueryService(
    this._database, {
    CatalogEntrySummaryMapper mapper = const CatalogEntrySummaryMapper(),
    CatalogReadErrorMapper errorMapper = const CatalogReadErrorMapper(),
  })  : _mapper = mapper,
        _errorMapper = errorMapper;

  final DatabaseProvider _database;
  final CatalogEntrySummaryMapper _mapper;
  final CatalogReadErrorMapper _errorMapper;

  @override
  Future<Result<Map<CatalogWordRef, CatalogMeaningSummary>>> readMeanings(
    Iterable<CatalogWordRef> words,
  ) async {
    late final List<_MeaningRow> rows;
    try {
      rows = await _fetchMeanings(words);
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.query(cause, stackTrace));
    }

    try {
      final result = <CatalogWordRef, CatalogMeaningSummary>{};
      for (final row in rows) {
        final meaning = _mapper.meaning(
          row.html,
          isConjugation: row.isConjugation,
        );
        if (meaning != null) result[row.word] = meaning;
      }
      return Result.success(result);
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.conversion(cause, stackTrace));
    }
  }

  @override
  Future<Result<Map<CatalogWordRef, CatalogHeadwordMetadata>>>
      readHeadwordMetadata(Iterable<CatalogWordRef> words) async {
    late final List<_HeadwordRow> rows;
    try {
      rows = await _fetchHeadwordMetadata(words);
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.query(cause, stackTrace));
    }

    try {
      return Result.success({
        for (final row in rows) row.word: _mapper.headword(row.html),
      });
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.conversion(cause, stackTrace));
    }
  }

  Future<List<_MeaningRow>> _fetchMeanings(
    Iterable<CatalogWordRef> words,
  ) async {
    final refs = _firstRefs(words);
    final results = <_MeaningRow>[];
    final espRefs = refs[CatalogId.espJpnMain] ?? const {};
    if (espRefs.isNotEmpty) {
      final conjugations = await (_database.select(_database.espConjugations)
            ..where((table) => table.wordId.isIn(espRefs.keys)))
          .get();
      final conjugationMeanings = <int, String>{};
      for (final row in conjugations) {
        if (row.meaning?.trim().isNotEmpty ?? false) {
          conjugationMeanings[row.wordId] = row.meaning!;
        }
      }
      final dictionaries = await (_database.select(_database.espJpnDictionaries)
            ..where((table) => table.wordId.isIn(espRefs.keys))
            ..orderBy([(table) => OrderingTerm.asc(table.dictionaryId)]))
          .get();
      final dictionaryMeanings = <int, String>{};
      for (final row in dictionaries) {
        if (row.content?.trim().isNotEmpty ?? false) {
          dictionaryMeanings.putIfAbsent(row.wordId, () => row.content!);
        }
      }
      for (final entry in espRefs.entries) {
        final conjugation = conjugationMeanings[entry.key];
        final html = conjugation ?? dictionaryMeanings[entry.key];
        if (html != null) {
          results.add((
            word: entry.value,
            html: html,
            isConjugation: conjugation != null,
          ));
        }
      }
    }

    final jpnRefs = refs[CatalogId.jpnEspMain] ?? const {};
    if (jpnRefs.isNotEmpty) {
      final dictionaries = await (_database.select(_database.jpnEspDictionaries)
            ..where((table) => table.wordId.isIn(jpnRefs.keys))
            ..orderBy([(table) => OrderingTerm.asc(table.dictionaryId)]))
          .get();
      final meanings = <int, String>{};
      for (final row in dictionaries) {
        if (row.content.trim().isNotEmpty) {
          meanings.putIfAbsent(row.wordId, () => row.content);
        }
      }
      for (final entry in jpnRefs.entries) {
        final html = meanings[entry.key];
        if (html != null) {
          results.add((word: entry.value, html: html, isConjugation: false));
        }
      }
    }
    return results;
  }

  Future<List<_HeadwordRow>> _fetchHeadwordMetadata(
    Iterable<CatalogWordRef> words,
  ) async {
    final refs = _firstRefs(words);
    final results = <_HeadwordRow>[];
    final espRefs = refs[CatalogId.espJpnMain] ?? const {};
    if (espRefs.isNotEmpty) {
      final rows = await (_database.select(_database.espJpnDictionaries)
            ..where((table) => table.wordId.isIn(espRefs.keys))
            ..orderBy([(table) => OrderingTerm.asc(table.dictionaryId)]))
          .get();
      final headwords = <int, String>{};
      for (final row in rows) {
        if (row.headword?.trim().isNotEmpty ?? false) {
          headwords.putIfAbsent(row.wordId, () => row.headword!);
        }
      }
      _appendHeadwords(results, espRefs, headwords);
    }
    final jpnRefs = refs[CatalogId.jpnEspMain] ?? const {};
    if (jpnRefs.isNotEmpty) {
      final rows = await (_database.select(_database.jpnEspDictionaries)
            ..where((table) => table.wordId.isIn(jpnRefs.keys))
            ..orderBy([(table) => OrderingTerm.asc(table.dictionaryId)]))
          .get();
      final headwords = <int, String>{};
      for (final row in rows) {
        if (row.headword.trim().isNotEmpty) {
          headwords.putIfAbsent(row.wordId, () => row.headword);
        }
      }
      _appendHeadwords(results, jpnRefs, headwords);
    }
    return results;
  }
}

Map<CatalogId, Map<int, CatalogWordRef>> _firstRefs(
  Iterable<CatalogWordRef> words,
) {
  final refs = <CatalogId, Map<int, CatalogWordRef>>{};
  for (final word in words) {
    (refs[word.catalogId] ??= <int, CatalogWordRef>{})
        .putIfAbsent(word.wordId, () => word);
  }
  return refs;
}

void _appendHeadwords(
  List<_HeadwordRow> target,
  Map<int, CatalogWordRef> refs,
  Map<int, String> headwords,
) {
  for (final entry in refs.entries) {
    final html = headwords[entry.key];
    if (html != null) target.add((word: entry.value, html: html));
  }
}
