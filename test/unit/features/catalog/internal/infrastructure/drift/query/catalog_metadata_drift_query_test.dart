import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/catalog_entry_summary_drift_query.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/catalog_ranking_drift_query.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

void main() {
  late DatabaseProvider database;

  setUp(() {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('Esp meaning prefers non-empty conjugation then dictionary fallback',
      () async {
    await _insertEspWord(database, 1, 'hablar');
    await _insertEspWord(database, 2, 'comer');
    await _insertEspDictionary(
      database,
      dictionaryId: 1,
      wordId: 1,
      word: 'hablar',
      content: '<p data-orgtag="meaning">dictionary hablar</p>',
      htmlRaw: '<p data-orgtag="meaning">wrong html hablar</p>',
    );
    await _insertEspDictionary(
      database,
      dictionaryId: 2,
      wordId: 2,
      word: 'comer',
      content: '   ',
      htmlRaw: '<p data-orgtag="meaning">wrong first row</p>',
    );
    await _insertEspDictionary(
      database,
      dictionaryId: 3,
      wordId: 2,
      word: 'comer',
      content: '<p data-orgtag="meaning">dictionary comer</p>',
      htmlRaw: '<p data-orgtag="meaning">wrong html comer</p>',
    );
    await database.into(database.espConjugations).insert(
          EspConjugationsCompanion.insert(
            wordId: const Value(1),
            word: 'hablar',
            meaning: const Value('  conjugation hablar  '),
          ),
        );
    await database.into(database.espConjugations).insert(
          EspConjugationsCompanion.insert(
            wordId: const Value(2),
            word: 'comer',
            meaning: const Value('   '),
          ),
        );
    const hablar = CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: 1,
    );
    const comer = CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: 2,
    );

    final rows = await CatalogEntrySummaryDriftQuery(database)
        .fetchMeanings([hablar, comer]);

    expect(rows.map((row) => row.html), [
      '  conjugation hablar  ',
      '<p data-orgtag="meaning">dictionary comer</p>',
    ]);
    expect(identical(rows.first.word, hablar), isTrue);
  });

  test('Jpn summary uses the first dictionary and omits missing keys',
      () async {
    await _insertJpnWord(database, 7, '家');
    await _insertJpnWord(database, 8, '空');
    await _insertJpnDictionary(
      database,
      dictionaryId: 2,
      wordId: 7,
      word: '家',
      content: 'second',
    );
    await _insertJpnDictionary(
      database,
      dictionaryId: 1,
      wordId: 7,
      word: '家',
      content: 'first',
    );
    const present = CatalogWordRef(
      catalogId: CatalogId.jpnEspMain,
      wordId: 7,
    );
    const missing = CatalogWordRef(
      catalogId: CatalogId.jpnEspMain,
      wordId: 8,
    );

    final query = CatalogEntrySummaryDriftQuery(database);
    final meanings = await query.fetchMeanings([present, missing]);
    final metadata = await query.fetchHeadwordMetadata([present, missing]);

    expect(meanings.single.html, '<p data-orgtag="meaning">first</p>');
    expect(metadata.single.headwordHtml, '家<sup>(****)</sup>');
    expect(identical(meanings.single.word, present), isTrue);
  });

  test('ranking query handles a row, missing word, and another catalog',
      () async {
    await _insertEspWord(database, 1, 'uno');
    await _insertEspWord(database, 2, 'dos');
    await database.into(database.rankings).insert(
          RankingsCompanion.insert(
            wordId: const Value(1),
            rankingId: const Value(10),
            rankingNo: 23,
          ),
        );
    await database.into(database.rankings).insert(
          RankingsCompanion.insert(
            wordId: const Value(1),
            rankingId: const Value(20),
            rankingNo: 7,
          ),
        );
    await database.into(database.rankings).insert(
          RankingsCompanion.insert(
            rankingId: const Value(30),
            rankingNo: 1,
          ),
        );
    const ranked = CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: 1,
    );

    final rows = await CatalogRankingDriftQuery(database).fetch([
      ranked,
      const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 2),
      const CatalogWordRef(catalogId: CatalogId.jpnEspMain, wordId: 1),
    ]);

    expect(rows.single.rankingNo, 7);
    expect(identical(rows.single.word, ranked), isTrue);
  });
}

Future<void> _insertEspWord(
  DatabaseProvider database,
  int id,
  String word,
) =>
    database.into(database.espJpnWords).insert(
          EspJpnWordsCompanion.insert(wordId: Value(id), word: word),
        );

Future<void> _insertJpnWord(
  DatabaseProvider database,
  int id,
  String word,
) =>
    database.into(database.jpnEspWords).insert(
          JpnEspWordsCompanion.insert(wordId: Value(id), word: word),
        );

Future<void> _insertEspDictionary(
  DatabaseProvider database, {
  required int dictionaryId,
  required int wordId,
  required String word,
  required String content,
  required String htmlRaw,
}) =>
    database.into(database.espJpnDictionaries).insert(
          EspJpnDictionariesCompanion.insert(
            dictionaryId: Value(dictionaryId),
            wordId: wordId,
            word: word,
            headword: Value('$word<sup>(**)</sup>'),
            content: Value(content),
            htmlRaw: Value(htmlRaw),
          ),
        );

Future<void> _insertJpnDictionary(
  DatabaseProvider database, {
  required int dictionaryId,
  required int wordId,
  required String word,
  required String content,
}) =>
    database.into(database.jpnEspDictionaries).insert(
          JpnEspDictionariesCompanion.insert(
            dictionaryId: Value(dictionaryId),
            wordId: wordId,
            word: word,
            excf: 4,
            headword: '$word<sup>(****)</sup>',
            content: '<p data-orgtag="meaning">$content</p>',
            htmlRaw: '<p data-orgtag="meaning">wrong $content</p>',
          ),
        );
