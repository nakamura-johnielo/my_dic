import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

final class CatalogMeaningDriftRow {
  const CatalogMeaningDriftRow({
    required this.word,
    required this.html,
    required this.source,
  });

  final CatalogWordRef word;
  final String html;
  final CatalogMeaningDriftSource source;
}

enum CatalogMeaningDriftSource { conjugation, dictionaryContent }

final class CatalogHeadwordMetadataDriftRow {
  const CatalogHeadwordMetadataDriftRow({
    required this.word,
    required this.headwordHtml,
  });

  final CatalogWordRef word;
  final String headwordHtml;
}

/// Catalog-owned batch queries for summary data used by enrichment readers.
final class CatalogEntrySummaryDriftQuery {
  const CatalogEntrySummaryDriftQuery(this._database);

  final DatabaseProvider _database;

  Future<List<CatalogMeaningDriftRow>> fetchMeanings(
    Iterable<CatalogWordRef> words,
  ) async {
    final refs = _firstRefs(words);
    final results = <CatalogMeaningDriftRow>[];

    final espRefs = refs[CatalogId.espJpnMain] ?? const {};
    if (espRefs.isNotEmpty) {
      final conjugations = await (_database.select(_database.espConjugations)
            ..where((table) => table.wordId.isIn(espRefs.keys)))
          .get();
      final conjugationMeanings = <int, String>{};
      for (final row in conjugations) {
        final meaning = row.meaning?.trim();
        if (meaning != null && meaning.isNotEmpty) {
          conjugationMeanings[row.wordId] = row.meaning!;
        }
      }

      final dictionaries = await (_database.select(_database.espJpnDictionaries)
            ..where((table) => table.wordId.isIn(espRefs.keys))
            ..orderBy([(table) => OrderingTerm.asc(table.dictionaryId)]))
          .get();
      final dictionaryMeanings = <int, String>{};
      for (final row in dictionaries) {
        final value = row.content;
        if (value != null && value.trim().isNotEmpty) {
          dictionaryMeanings.putIfAbsent(row.wordId, () => value);
        }
      }

      for (final entry in espRefs.entries) {
        final conjugation = conjugationMeanings[entry.key];
        final value = conjugation ?? dictionaryMeanings[entry.key];
        if (value != null) {
          results.add(CatalogMeaningDriftRow(
            word: entry.value,
            html: value,
            source: conjugation == null
                ? CatalogMeaningDriftSource.dictionaryContent
                : CatalogMeaningDriftSource.conjugation,
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
        final value = row.content;
        if (value.trim().isNotEmpty) {
          meanings.putIfAbsent(row.wordId, () => value);
        }
      }
      for (final entry in jpnRefs.entries) {
        final value = meanings[entry.key];
        if (value != null) {
          results.add(CatalogMeaningDriftRow(
            word: entry.value,
            html: value,
            source: CatalogMeaningDriftSource.dictionaryContent,
          ));
        }
      }
    }
    return results;
  }

  Future<List<CatalogHeadwordMetadataDriftRow>> fetchHeadwordMetadata(
    Iterable<CatalogWordRef> words,
  ) async {
    final refs = _firstRefs(words);
    final results = <CatalogHeadwordMetadataDriftRow>[];

    final espRefs = refs[CatalogId.espJpnMain] ?? const {};
    if (espRefs.isNotEmpty) {
      final rows = await (_database.select(_database.espJpnDictionaries)
            ..where((table) => table.wordId.isIn(espRefs.keys))
            ..orderBy([(table) => OrderingTerm.asc(table.dictionaryId)]))
          .get();
      final headwords = <int, String>{};
      for (final row in rows) {
        final value = row.headword;
        if (value != null && value.trim().isNotEmpty) {
          headwords.putIfAbsent(row.wordId, () => value);
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
  List<CatalogHeadwordMetadataDriftRow> target,
  Map<int, CatalogWordRef> refs,
  Map<int, String> headwords,
) {
  for (final entry in refs.entries) {
    final headword = headwords[entry.key];
    if (headword != null) {
      target.add(CatalogHeadwordMetadataDriftRow(
        word: entry.value,
        headwordHtml: headword,
      ));
    }
  }
}
