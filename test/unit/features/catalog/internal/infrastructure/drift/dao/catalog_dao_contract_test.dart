import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/conjugation_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/dictionary_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/example_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/idiom_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/supplement_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/esp_jpn_word_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/jpn_esp/jpn_esp_dictionary_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/jpn_esp/jpn_esp_example_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/reader/drift_catalog_ranking_reader.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

void main() {
  late DatabaseProvider database;

  setUp(() {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('Esp-Jpn DAO ordering and nullable fallback remain stable', () async {
    await database.into(database.espJpnWords).insert(
          EspJpnWordsCompanion.insert(wordId: const Value(1), word: 'casa'),
        );
    await database.into(database.espJpnDictionaries).insert(
          EspJpnDictionariesCompanion.insert(
            dictionaryId: const Value(20),
            wordId: 1,
            word: 'casa',
            headword: const Value('second'),
            content: const Value('second content'),
          ),
        );
    await database.into(database.espJpnDictionaries).insert(
          EspJpnDictionariesCompanion.insert(
            dictionaryId: const Value(10),
            wordId: 1,
            word: 'casa',
            headword: const Value('first'),
            content: const Value('first content'),
          ),
        );

    final dictionaryDao = EspjpnDictionaryDao(database);
    expect(await dictionaryDao.getFirstContentByWordId(1), 'first content');
    expect(await dictionaryDao.getFirstHeadwordByWordId(1), 'first');
    expect(await dictionaryDao.getContentById(999), isNull);

    for (final id in [3, 1, 2]) {
      await database.into(database.espJpnExamples).insert(
            EspJpnExamplesCompanion.insert(
              exampleId: Value(id),
              dictionaryId: const Value(10),
              exampleNo: id,
              espanolHtml: 'html-$id',
              japaneseText: 'ja-$id',
              espanolText: 'es-$id',
            ),
          );
      await database.into(database.espJpnIdioms).insert(
            EspJpnIdiomsCompanion.insert(
              idiomId: Value(id),
              dictionaryId: const Value(10),
              idiomNo: id,
              idiom: 'idiom-$id',
              description: 'description-$id',
            ),
          );
      await database.into(database.espJpnSupplements).insert(
            EspJpnSupplementsCompanion.insert(
              supplementId: Value(id),
              dictionaryId: const Value(10),
              supplementNo: id,
              content: 'supplement-$id',
            ),
          );
    }

    expect(
      (await EspJpnExampleDao(database).getExampleByDictionaryId(10))
          .map((row) => row.exampleId),
      [1, 2, 3],
    );
    expect(
      (await EspJpnIdiomDao(database).getExampleByDictionaryId(10))
          .map((row) => row.idiomId),
      [1, 2, 3],
    );
    expect(
      (await EspJpnSupplementDao(database).getExampleByDictionaryId(10))
          .map((row) => row.supplementId),
      [1, 2, 3],
    );
  });

  test('Jpn-Esp first-content and example ordering remain stable', () async {
    await database.into(database.jpnEspWords).insert(
          JpnEspWordsCompanion.insert(wordId: const Value(1), word: '家'),
        );
    for (final entry in [(30, 'third'), (10, 'first'), (20, 'second')]) {
      await database.into(database.jpnEspDictionaries).insert(
            JpnEspDictionariesCompanion.insert(
              dictionaryId: Value(entry.$1),
              wordId: 1,
              word: '家',
              excf: 0,
              headword: entry.$2,
              content: entry.$2,
              htmlRaw: '<p>${entry.$2}</p>',
            ),
          );
    }

    expect(
      await JpnEspDictionaryDao(database).getFirstContentsByWordIds([1]),
      {1: 'first'},
    );

    for (final id in [3, 1, 2]) {
      await database.into(database.jpnEspExamples).insert(
            JpnEspExamplesCompanion.insert(
              exampleId: Value(id),
              dictionaryId: 10,
              exampleNo: id,
              japaneseText: 'ja-$id',
              espanolHtml: 'html-$id',
              espanolText: 'es-$id',
            ),
          );
    }
    expect(
      (await JpnEspExampleDao(database).getExampleByDictionaryId(10))
          .map((row) => row.exampleId),
      [1, 2, 3],
    );
  });

  test(
      'word prefix paging retains the current SQLite row observation order '
      'without promising lexical ordering', () async {
    // Insert, word-id, and lexical orders deliberately differ. The DAO has no
    // ORDER BY; this only characterizes the current SQLite observation order.
    for (final entry in [(30, 'cacao'), (10, 'cama'), (20, 'cabra')]) {
      await database.into(database.espJpnWords).insert(
            EspJpnWordsCompanion.insert(
              wordId: Value(entry.$1),
              word: entry.$2,
            ),
          );
    }
    final dao = EspJpnWordDao(database);

    final first = await dao.getWordsByWordByPage('ca', 2, 0);
    final last = await dao.getWordsByWordByPage('ca', 2, 1);

    expect(first.map((row) => row.word), ['cama', 'cabra']);
    expect(last.map((row) => row.word), ['cacao']);
  });

  test('conjugation exact matches sort before prefix-only matches', () async {
    await database.customStatement('''
      INSERT INTO words (word_id, word) VALUES
        (1, 'hablar'), (2, 'haber')
    ''');
    await database.customStatement('''
      INSERT INTO conjugations
        (word_id, word, indicative_present_yo)
      VALUES
        (1, 'hablar', 'hablo'),
        (2, 'haber', 'habloque')
    ''');

    final rows = await ConjugationDao(database)
        .getConjugationByWordWithPage('hablo', 2, 0);

    expect(rows.map((row) => row.wordId), [1, 2]);
    expect(rows.first.indicativePresentYo, 'hablo');
  });

  test('ranking query chooses the smallest ranking number for each word',
      () async {
    await database.customStatement(
      "INSERT INTO words (word_id, word) VALUES (1, 'casa')",
    );
    await database.customStatement('''
      INSERT INTO rankings
        (ranking_id, ranking_no, word, word_origin, word_id)
      VALUES
        (10, 300, 'casa', 'casa', 1),
        (20, 100, 'casa', 'casa', 1)
    ''');

    const word = CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: 1,
    );
    final result = await DriftCatalogRankingQueryService(database)
        .readRankingMetadata([word]);
    final rows = result.dataOrNull!;

    expect(rows[word]!.rankingNo, 100);
    expect(identical(rows.keys.single, word), isTrue);
  });
}
