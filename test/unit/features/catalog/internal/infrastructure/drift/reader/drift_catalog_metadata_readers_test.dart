import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/reader/drift_catalog_entry_summary_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/reader/drift_catalog_ranking_reader.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/error/catalog_read_error.dart';

void main() {
  late DatabaseProvider database;

  setUp(() {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    try {
      await database.close();
    } on StateError {
      // A test deliberately closes the database before reading.
    }
  });

  test('summary reader removes HTML and maps frequency levels 0 through 4+',
      () async {
    for (var id = 1; id <= 6; id++) {
      await database.into(database.espJpnWords).insert(
            EspJpnWordsCompanion.insert(
              wordId: Value(id),
              word: 'word$id',
            ),
          );
      final stars =
          id == 1 ? '' : '<sup>(${List.filled(id - 1, '*').join()})</sup>';
      await database.into(database.espJpnDictionaries).insert(
            EspJpnDictionariesCompanion.insert(
              dictionaryId: Value(id),
              wordId: id,
              word: 'word$id',
              headword: Value('<b>word&amp;$id</b>$stars'),
              content: Value(
                '<aside data-orgtag="note">ignore $id</aside>'
                '<p class="entry" data-orgtag="meaning">'
                'meaning&nbsp;$id <b>nested</b></p>'
                '<div data-orgtag="meaning"><i>second</i> $id</div>',
              ),
              htmlRaw: Value(
                '<p data-orgtag="meaning">wrong html raw $id</p>',
              ),
            ),
          );
    }
    final words = [
      for (var id = 1; id <= 6; id++)
        CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: id),
    ];
    final reader = DriftCatalogEntrySummaryQueryService(database);

    final meanings = (await reader.readMeanings(words)).dataOrNull!;
    final metadata = (await reader.readHeadwordMetadata(words)).dataOrNull!;

    expect(meanings[words.first]!.meaning, 'meaning 1 nested  second 1');
    expect(metadata.values.map((value) => value.headword), [
      'word&1',
      'word&2',
      'word&3',
      'word&4',
      'word&5',
      'word&6',
    ]);
    expect(
      metadata.values.map((value) => value.frequencyLevel.value),
      [0, 1, 2, 3, 4, 5],
    );
    expect(identical(metadata.keys.first, words.first), isTrue);
  });

  test('readers omit absent entries and ranking metadata is typed', () async {
    await database.into(database.espJpnWords).insert(
          EspJpnWordsCompanion.insert(
            wordId: const Value(1),
            word: 'uno',
          ),
        );
    await database.into(database.rankings).insert(
          RankingsCompanion.insert(
            wordId: const Value(1),
            rankingId: const Value(3),
            rankingNo: 11,
          ),
        );
    await database.into(database.rankings).insert(
          RankingsCompanion.insert(
            wordId: const Value(1),
            rankingId: const Value(4),
            rankingNo: 5,
          ),
        );
    const existing = CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: 1,
    );
    const missing = CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: 2,
    );

    final meanings = await DriftCatalogEntrySummaryQueryService(database)
        .readMeanings([existing, missing]);
    final rankings = await DriftCatalogRankingQueryService(database)
        .readRankingMetadata([existing, missing]);

    expect(meanings.dataOrNull, isEmpty);
    expect(rankings.dataOrNull, hasLength(1));
    expect(rankings.dataOrNull![existing]!.rankingNo, 5);
    expect(identical(rankings.dataOrNull!.keys.single, existing), isTrue);
  });

  test('non-empty conjugation meaning stays preferred and becomes plain text',
      () async {
    await database.into(database.espJpnWords).insert(
          EspJpnWordsCompanion.insert(
            wordId: const Value(9),
            word: 'hablar',
          ),
        );
    await database.into(database.espJpnDictionaries).insert(
          EspJpnDictionariesCompanion.insert(
            dictionaryId: const Value(9),
            wordId: 9,
            word: 'hablar',
            content: const Value(
              '<p data-orgtag="meaning">dictionary fallback</p>',
            ),
            htmlRaw: const Value(
              '<p data-orgtag="meaning">wrong html raw</p>',
            ),
          ),
        );
    await database.into(database.espConjugations).insert(
          EspConjugationsCompanion.insert(
            wordId: const Value(9),
            word: 'hablar',
            meaning: const Value('<b>preferred</b>&nbsp;meaning'),
          ),
        );
    const word = CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: 9,
    );

    final result =
        await DriftCatalogEntrySummaryQueryService(database).readMeanings([word]);

    expect(result.dataOrNull![word]!.meaning, 'preferred meaning');
  });

  test('non-meaning dictionary content omits Esp and Jpn keys', () async {
    await database.into(database.espJpnWords).insert(
          EspJpnWordsCompanion.insert(
            wordId: const Value(20),
            word: 'nada',
          ),
        );
    await database.into(database.espJpnDictionaries).insert(
          EspJpnDictionariesCompanion.insert(
            dictionaryId: const Value(20),
            wordId: 20,
            word: 'nada',
            content: const Value('<p data-orgtag="note">not a meaning</p>'),
            htmlRaw: const Value(
              '<p data-orgtag="meaning">must be ignored</p>',
            ),
          ),
        );
    await database.into(database.jpnEspWords).insert(
          JpnEspWordsCompanion.insert(
            wordId: const Value(21),
            word: '無',
          ),
        );
    await database.into(database.jpnEspDictionaries).insert(
          JpnEspDictionariesCompanion.insert(
            dictionaryId: const Value(21),
            wordId: 21,
            word: '無',
            excf: 0,
            headword: '無',
            content: '<div data-orgtag="example">not a meaning</div>',
            htmlRaw: '<p data-orgtag="meaning">must be ignored</p>',
          ),
        );
    const esp = CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: 20,
    );
    const jpn = CatalogWordRef(
      catalogId: CatalogId.jpnEspMain,
      wordId: 21,
    );

    final result =
        await DriftCatalogEntrySummaryQueryService(database)
            .readMeanings([esp, jpn]);

    expect(result.dataOrNull, isEmpty);
  });

  test('database error is unavailable and preserves cause and stack', () async {
    final summaryReader = DriftCatalogEntrySummaryQueryService(database);
    final rankingReader = DriftCatalogRankingQueryService(database);
    await database.customStatement('DROP TABLE dictionaries');
    await database.customStatement('DROP TABLE rankings');
    const word = CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: 1,
    );

    final summary = await summaryReader.readMeanings([word]);
    final ranking = await rankingReader.readRankingMetadata([word]);

    for (final error in [summary.errorOrNull, ranking.errorOrNull]) {
      expect(error, isA<CatalogDataUnavailableError>());
      expect(error!.originalError, isNotNull);
      expect(error.stackTrace, isNotNull);
    }
  });
}
