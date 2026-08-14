import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_read_error_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/reader/drift_catalog_conjugation_search_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/reader/drift_catalog_word_search_reader.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/error/catalog_read_error.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';
import 'package:my_dic/features/catalog/port/model/catalog_search_models.dart';
import 'package:my_dic/features/catalog/port/query/catalog_conjugation_search_query.dart';
import 'package:my_dic/features/catalog/port/query/catalog_word_search_query.dart';

void main() {
  late DatabaseProvider database;

  setUp(() {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    try {
      await database.close();
    } on StateError {
      // One test deliberately closes the database before reading.
    }
  });

  test('word reader truncates look-ahead and reports exact hasMore', () async {
    for (var id = 1; id <= 3; id++) {
      await database.into(database.espJpnWords).insert(
            EspJpnWordsCompanion.insert(
              wordId: Value(id),
              word: 'casa$id',
              partOfSpeech: Value(CatalogPartOfSpeech.verb.wireValue),
            ),
          );
    }
    final reader = DriftCatalogWordSearchQueryService(database);

    final first = await reader.searchWords(_wordQuery(page: 0, size: 2));
    final last = await reader.searchWords(_wordQuery(page: 1, size: 2));

    expect(first.dataOrNull!.items.length, 2);
    expect(first.dataOrNull!.hasMore, isTrue);
    expect(first.dataOrNull!.items.first.hasConjugation, isTrue);
    expect(last.dataOrNull!.items.map((hit) => hit.word.wordId), [3]);
    expect(last.dataOrNull!.hasMore, isFalse);
  });

  test('word reader returns a successful empty page', () async {
    final result = await DriftCatalogWordSearchQueryService(database)
        .searchWords(_wordQuery(page: 0, size: 2));

    expect(result.dataOrNull!.items, isEmpty);
    expect(result.dataOrNull!.hasMore, isFalse);
  });

  test('conjugation reader exposes only typed matching forms', () async {
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
            presentParticiple: const Value('hablando'),
            pastParticiple: const Value('hablado'),
            indicativePresentYo: const Value('hablo'),
          ),
        );

    final result = await DriftCatalogConjugationSearchQueryService(database)
        .searchConjugations(CatalogConjugationSearchQuery(
      catalogId: CatalogId.espJpnMain,
      text: 'habl',
      page: 0,
      size: 1,
    ));

    final matches = result.dataOrNull!.items.single.matches;
    expect(
      matches[const CatalogConjugationMatch(
        moodTense: CatalogMoodTense.participlePresent,
      )],
      'hablando',
    );
    expect(
      matches[const CatalogConjugationMatch(
        moodTense: CatalogMoodTense.indicativePresent,
        subject: CatalogSubject.yo,
      )],
      'hablo',
    );
  });

  test('conjugation reader pages with look-ahead and size-based offset',
      () async {
    for (var id = 1; id <= 4; id++) {
      await database.into(database.espJpnWords).insert(
            EspJpnWordsCompanion.insert(
              wordId: Value(id),
              word: 'hab$id',
            ),
          );
      await database.into(database.espConjugations).insert(
            EspConjugationsCompanion.insert(
              wordId: Value(id),
              word: 'hab$id',
            ),
          );
    }
    final reader = DriftCatalogConjugationSearchQueryService(database);

    final first = await reader.searchConjugations(_conjugationQuery(page: 0));
    final last = await reader.searchConjugations(_conjugationQuery(page: 1));

    expect(first.dataOrNull!.items.map((hit) => hit.word.wordId), [1, 2]);
    expect(first.dataOrNull!.hasMore, isTrue);
    expect(last.dataOrNull!.items.map((hit) => hit.word.wordId), [3, 4]);
    expect(last.dataOrNull!.hasMore, isFalse);
    expect(last.dataOrNull!.items.every((hit) => hit.matches.isEmpty), isTrue);
  });

  test('conversion errors route corrupted data separately from reader defects',
      () {
    const mapper = CatalogReadErrorMapper();
    final stackTrace = StackTrace.current;
    final format = FormatException('bad persisted value');
    final range = RangeError.value(-1);
    final argument = ArgumentError.value('bad');
    final defect = StateError('mapper bug');

    for (final cause in [format, range, argument]) {
      final error = mapper.conversion(cause, stackTrace);
      expect(error, isA<CatalogDataCorruptedError>());
      expect(error.originalError, same(cause));
      expect(error.stackTrace, same(stackTrace));
    }
    final unexpected = mapper.conversion(defect, stackTrace);
    expect(unexpected, isA<CatalogUnexpectedReadError>());
    expect(unexpected.originalError, same(defect));
    expect(unexpected.stackTrace, same(stackTrace));
  });

  test('database failures become unavailable and preserve their cause',
      () async {
    final reader = DriftCatalogWordSearchQueryService(database);
    await database.customStatement('DROP TABLE words');

    final result = await reader.searchWords(_wordQuery(page: 0, size: 2));
    final error = result.errorOrNull;

    expect(error, isA<CatalogDataUnavailableError>());
    expect(error!.originalError, isNotNull);
    expect(error.stackTrace, isNotNull);
  });
}

CatalogWordSearchQuery _wordQuery({required int page, required int size}) =>
    CatalogWordSearchQuery(
      catalogId: CatalogId.espJpnMain,
      text: 'casa',
      page: page,
      size: size,
    );

CatalogConjugationSearchQuery _conjugationQuery({required int page}) =>
    CatalogConjugationSearchQuery(
      catalogId: CatalogId.espJpnMain,
      text: 'hab',
      page: page,
      size: 2,
    );
