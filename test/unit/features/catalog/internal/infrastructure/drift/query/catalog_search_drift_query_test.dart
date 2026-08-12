import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/catalog_conjugation_search_drift_query.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/catalog_like_pattern.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/catalog_word_search_drift_query.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/query/catalog_conjugation_search_query.dart';
import 'package:my_dic/features/catalog/port/query/catalog_word_search_query.dart';

void main() {
  late DatabaseProvider database;

  setUp(() {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('prefix pattern escapes user wildcards and appends one wildcard', () {
    expect(catalogPrefixLikePattern("a!%_'"), "a!!!%!_'%");
  });

  test("word query treats quote, percent, underscore, and bang literally",
      () async {
    final words = [
      (1, "o'clock"),
      (2, 'a%literal'),
      (3, 'axliteral'),
      (4, 'a_literal'),
      (5, 'ayliteral'),
      (6, 'a!literal'),
      (7, 'all'),
    ];
    for (final entry in words) {
      await database.into(database.espJpnWords).insert(
            EspJpnWordsCompanion.insert(
              wordId: Value(entry.$1),
              word: entry.$2,
            ),
          );
    }

    Future<List<int>> search(String text) async =>
        (await CatalogWordSearchDriftQuery(database).fetch(
          CatalogWordSearchQuery(
            catalogId: CatalogId.espJpnMain,
            text: text,
            page: 0,
            size: 10,
          ),
        ))
            .cast<EspJpnWordSearchDriftRow>()
            .map((row) => row.row.wordId)
            .toList();

    expect(await search("o'"), [1]);
    expect(await search('a%'), [2]);
    expect(await search('a_'), [4]);
    expect(await search('a!'), [6]);
    expect(await search("x' OR 1=1 --"), isEmpty);
  });

  test('word look-ahead keeps offset based on requested page size', () async {
    for (final entry in [
      (1, 'casa'),
      (2, 'casar'),
      (3, 'casco'),
      (4, 'casilla')
    ]) {
      await database.into(database.espJpnWords).insert(
            EspJpnWordsCompanion.insert(
              wordId: Value(entry.$1),
              word: entry.$2,
            ),
          );
    }

    final rows = await CatalogWordSearchDriftQuery(database).fetch(
      CatalogWordSearchQuery(
        catalogId: CatalogId.espJpnMain,
        text: 'cas',
        page: 1,
        size: 2,
      ),
    );

    expect(
      rows.cast<EspJpnWordSearchDriftRow>().map((row) => row.row.wordId),
      [3, 4],
    );
  });

  test('word query dispatches to the Japanese-Spanish table', () async {
    await database.into(database.jpnEspWords).insert(
          JpnEspWordsCompanion.insert(wordId: const Value(8), word: '家'),
        );

    final rows = await CatalogWordSearchDriftQuery(database).fetch(
      CatalogWordSearchQuery(
        catalogId: CatalogId.jpnEspMain,
        text: '家',
        page: 0,
        size: 1,
      ),
    );

    expect((rows.single as JpnEspWordSearchDriftRow).row.wordId, 8);
  });

  test('conjugation query includes lemma-only matches with no forms', () async {
    await database.into(database.espJpnWords).insert(
          EspJpnWordsCompanion.insert(
            wordId: const Value(1),
            word: 'hablar',
          ),
        );
    await database.into(database.espConjugations).insert(
          EspConjugationsCompanion.insert(
            wordId: const Value(1),
            word: 'hablar',
            indicativePresentYo: const Value('digo'),
          ),
        );

    final rows = await CatalogConjugationSearchDriftQuery(database).fetch(
      CatalogConjugationSearchQuery(
        catalogId: CatalogId.espJpnMain,
        text: 'hab',
        page: 0,
        size: 1,
      ),
    );

    expect(rows.single.row.wordId, 1);
  });

  test('exact word or form precedes prefixes with stable word-id ties',
      () async {
    for (final entry in [
      (1, 'hacer'),
      (2, 'haber'),
      (3, 'hablo'),
      (4, 'hablar'),
    ]) {
      await database.into(database.espJpnWords).insert(
            EspJpnWordsCompanion.insert(
              wordId: Value(entry.$1),
              word: entry.$2,
            ),
          );
    }
    await database.into(database.espConjugations).insert(
          EspConjugationsCompanion.insert(
            wordId: const Value(1),
            word: 'hacer',
            indicativePresentYo: const Value('hablo'),
          ),
        );
    await database.into(database.espConjugations).insert(
          EspConjugationsCompanion.insert(
            wordId: const Value(2),
            word: 'haber',
            indicativePresentYo: const Value('hablo'),
          ),
        );
    await database.into(database.espConjugations).insert(
          EspConjugationsCompanion.insert(
            wordId: const Value(3),
            word: 'hablo',
            indicativePresentYo: const Value('habloque'),
          ),
        );
    await database.into(database.espConjugations).insert(
          EspConjugationsCompanion.insert(
            wordId: const Value(4),
            word: 'hablar',
            indicativePresentYo: const Value('habloque'),
          ),
        );

    final rows = await CatalogConjugationSearchDriftQuery(database).fetch(
      CatalogConjugationSearchQuery(
        catalogId: CatalogId.espJpnMain,
        text: 'hablo',
        page: 0,
        size: 4,
      ),
    );

    expect(rows.map((row) => row.row.wordId), [1, 2, 3, 4]);
  });
}
