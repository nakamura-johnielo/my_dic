import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/drift_catalog_ranked_entry_feed_reader.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';

void main() {
  late DatabaseProvider database;

  setUp(() {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('preserves source identity, duplicate words, and deterministic order',
      () async {
    await _word(database, 1, 'hablar');
    await _word(database, 2, 'comer');
    await _ranking(database, id: 30, rank: 1, wordId: 2, word: 'como');
    await _ranking(database, id: 10, rank: 1, wordId: 1, word: 'hablo');
    await _ranking(database, id: 11, rank: 1, wordId: 1, word: 'hablas');
    await database.into(database.partOfSpeechLists).insert(
          PartOfSpeechListsCompanion.insert(
            partOfSpeechId: const Value(1),
            wordId: 1,
            partOfSpeech: CatalogPartOfSpeech.verb.wireValue,
          ),
        );
    await database.into(database.espConjugations).insert(
          EspConjugationsCompanion.insert(
            wordId: const Value(1),
            word: 'hablar',
          ),
        );

    final feed = (await DriftCatalogRankedEntryFeedQueryService(database)
            .readRankedEntries(
      CatalogRankedEntryFeedQuery(offset: 0, size: 2),
    ))
        .dataOrNull!;

    expect(feed.items.map((item) => item.entryRef.toSerialized()), [10, 11]);
    expect(feed.items.map((item) => item.rankingNo), [1, 1]);
    expect(feed.items.map((item) => item.word.wordId), [1, 1]);
    expect(feed.items.first.partsOfSpeech, {CatalogPartOfSpeech.verb});
    expect(feed.items.first.hasConjugation, isTrue);
    expect(feed.hasMore, isTrue);
  });

  test('uses size plus one and reports an exact-size final slice', () async {
    await _word(database, 1, 'uno');
    await _word(database, 2, 'dos');
    await _ranking(database, id: 1, rank: 1, wordId: 1, word: 'uno');
    await _ranking(database, id: 2, rank: 2, wordId: 2, word: 'dos');
    final reader = DriftCatalogRankedEntryFeedQueryService(database);

    final first = (await reader.readRankedEntries(
      CatalogRankedEntryFeedQuery(offset: 0, size: 1),
    ))
        .dataOrNull!;
    final finalSlice = (await reader.readRankedEntries(
      CatalogRankedEntryFeedQuery(offset: 1, size: 1),
    ))
        .dataOrNull!;

    expect(first.items, hasLength(1));
    expect(first.hasMore, isTrue);
    expect(finalSlice.items.single.entryRef.toSerialized(), 2);
    expect(finalSlice.hasMore, isFalse);
  });

  test('normalizes query failures at the Catalog boundary', () async {
    final cause = StateError('deterministic query failure');
    final reader = DriftCatalogRankedEntryFeedQueryService(
      database,
      fetch: ({required int offset, required int limit}) async {
        throw cause;
      },
    );

    final result = await reader.readRankedEntries(
      CatalogRankedEntryFeedQuery(offset: 0, size: 10),
    );

    expect(result.errorOrNull, isA<CatalogDataUnavailableError>());
    expect(result.errorOrNull!.originalError, same(cause));
    expect(result.errorOrNull!.stackTrace, isNotNull);
  });
}

Future<void> _word(DatabaseProvider database, int id, String word) =>
    database.into(database.espJpnWords).insert(
          EspJpnWordsCompanion.insert(wordId: Value(id), word: word),
        );

Future<void> _ranking(
  DatabaseProvider database, {
  required int id,
  required int rank,
  required int wordId,
  required String word,
}) =>
    database.into(database.rankings).insert(
          RankingsCompanion.insert(
            rankingId: Value(id),
            rankingNo: rank,
            wordId: Value(wordId),
            word: Value(word),
            wordOrigin: const Value('lemma'),
          ),
        );
