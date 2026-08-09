import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/dictionary_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/example_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/idiom_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/supplement_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/jpn_esp/jpn_esp_dictionary_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/jpn_esp/jpn_esp_example_dao.dart';

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
}
