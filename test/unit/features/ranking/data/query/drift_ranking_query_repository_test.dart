import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';
import 'package:my_dic/features/ranking/internal/infrastructure/drift/drift_ranking_query_repository.dart';
import 'package:my_dic/features/ranking/internal/infrastructure/drift/ranking_dao.dart';
import 'package:my_dic/features/ranking/internal/infrastructure/drift/ranking_query_row.dart';
import 'package:my_dic/features/ranking/port/model/ranking_query.dart';

void main() {
  late DatabaseProvider database;
  late DriftRankingQueryRepository repository;

  setUp(() async {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
    repository = DriftRankingQueryRepository(RankingDao(database));
    await _seed(database);
  });

  tearDown(() => database.close());

  group('DriftRankingQueryRepository', () {
    test('scopes status include and exclude predicates to the query account',
        () async {
      final accountAIncluded = await repository.fetchPage(RankingQuery(
        page: 0,
        size: 10,
        accountId: 'account-a',
        includedFeatureTags: {FeatureTag.isLearned},
      ));
      final accountBIncluded = await repository.fetchPage(RankingQuery(
        page: 0,
        size: 10,
        accountId: 'account-b',
        includedFeatureTags: {FeatureTag.isLearned},
      ));
      final accountAExcluded = await repository.fetchPage(RankingQuery(
        page: 0,
        size: 10,
        accountId: 'account-a',
        excludedFeatureTags: {FeatureTag.isLearned},
      ));

      expect(accountAIncluded.dataOrNull?.items.map((item) => item.wordId),
          [1, 1]);
      expect(
          accountBIncluded.dataOrNull?.items.map((item) => item.wordId), [2]);
      expect(accountAExcluded.dataOrNull?.items.map((item) => item.wordId),
          [2, 3]);
    });

    test('owns size plus one pagination and strips its look-ahead row',
        () async {
      final result = await repository.fetchPage(RankingQuery(
        page: 0,
        size: 2,
        accountId: 'account-a',
      ));

      expect(result.dataOrNull?.hasNext, isTrue);
      expect(result.dataOrNull?.items.map((item) => item.rank), [1, 2]);
    });

    test('multiLemma groups without changing the caller filter set', () async {
      final filters = {FeatureTag.multiLemma};
      final result = await repository.fetchPage(RankingQuery(
        page: 0,
        size: 10,
        accountId: 'account-a',
        includedFeatureTags: filters,
      ));

      expect(filters, {FeatureTag.multiLemma});
      expect(result.dataOrNull?.items.map((item) => item.wordId), [1, 2, 3]);
    });

    test('binds each supported status tag as an OR condition for its account',
        () async {
      await database.customStatement('''
        INSERT INTO word_status
          (word_id, is_bookmarked, has_note, edit_at, account_id, local_revision)
        VALUES
          (2, 1, 0, 'now', 'account-a', 0),
          (3, 0, 1, 'now', 'account-a', 0)
      ''');

      final result = await repository.fetchPage(RankingQuery(
        page: 0,
        size: 10,
        accountId: 'account-a',
        includedFeatureTags: {
          FeatureTag.isLearned,
          FeatureTag.isBookmarked,
          FeatureTag.hasNote,
        },
      ));

      expect(result.dataOrNull?.items.map((item) => item.wordId), [1, 2, 3, 1]);
    });

    test('applies status filters before offset across multiple pages',
        () async {
      await database.customStatement('DELETE FROM rankings');
      await database.customStatement('DELETE FROM word_status');
      await database.customStatement('''
        INSERT INTO rankings (ranking_id, ranking_no, word, word_origin, word_id)
        VALUES
          (1, 1, 'one', 'one', 1),
          (2, 2, 'two', 'two', 2),
          (3, 3, 'three', 'three', 3),
          (4, 4, 'four', 'four', 4),
          (5, 5, 'five', 'five', 5)
      ''');
      await database.customStatement('''
        INSERT INTO word_status
          (word_id, is_learned, edit_at, account_id, local_revision)
        VALUES
          (2, 1, 'now', 'account-a', 0),
          (4, 1, 'now', 'account-a', 0),
          (5, 1, 'now', 'account-a', 0)
      ''');

      Future<List<int>?> fetchPage(int page) async =>
          (await repository.fetchPage(RankingQuery(
            page: page,
            size: 1,
            accountId: 'account-a',
            includedFeatureTags: {FeatureTag.isLearned},
          )))
              .dataOrNull
              ?.items
              .map((item) => item.rank)
              .toList();

      expect(await fetchPage(0), [2]);
      expect(await fetchPage(1), [4]);
      expect(await fetchPage(2), [5]);
    });

    test(
        'paginates across invalid rows using valid rows for page size and hasNext',
        () async {
      await database.customStatement('DELETE FROM rankings');
      await database.customStatement('''
        INSERT INTO rankings
          (ranking_id, ranking_no, word, word_origin, word_id)
        VALUES
          (101, 187, 'word 187', 'word 187', 1),
          (102, 188, 'word 188', 'word 188', 2),
          (103, 189, NULL, 'invalid word', 3),
          (104, 190, 'invalid lemma', NULL, 3),
          (105, 191, 'invalid id', 'invalid id', NULL),
          (106, 192, 'word 192', 'word 192', 1),
          (107, 193, 'word 193', 'word 193', 2),
          (108, 194, 'word 194', 'word 194', 3)
      ''');

      final firstPage = await repository.fetchPage(RankingQuery(
        page: 0,
        size: 2,
        accountId: 'account-a',
      ));
      final secondPage = await repository.fetchPage(RankingQuery(
        page: 1,
        size: 2,
        accountId: 'account-a',
      ));
      final finalPage = await repository.fetchPage(RankingQuery(
        page: 2,
        size: 2,
        accountId: 'account-a',
      ));

      expect(firstPage.isSuccess, isTrue);
      expect(firstPage.dataOrNull?.items.map((item) => item.rank), [187, 188]);
      expect(firstPage.dataOrNull?.hasNext, isTrue);
      expect(secondPage.isSuccess, isTrue);
      expect(secondPage.dataOrNull?.items.map((item) => item.rank), [192, 193]);
      expect(secondPage.dataOrNull?.hasNext, isTrue);
      expect(finalPage.isSuccess, isTrue);
      expect(finalPage.dataOrNull?.items.map((item) => item.rank), [194]);
      expect(finalPage.dataOrNull?.hasNext, isFalse);
    });

    test('combines invalid-row exclusion with part-of-speech filters',
        () async {
      await database.customStatement('DELETE FROM rankings');
      await database.customStatement('DELETE FROM part_of_speech_lists');
      await database.customStatement('''
        INSERT INTO rankings
          (ranking_id, ranking_no, word, word_origin, word_id)
        VALUES
          (201, 1, 'first noun', 'first noun', 1),
          (202, 2, NULL, 'invalid noun', 1),
          (203, 3, 'not a noun', 'not a noun', 2),
          (204, 4, 'second noun', 'second noun', 1)
      ''');
      await database.customStatement(
        'INSERT INTO part_of_speech_lists '
        '(part_of_speech_id, word_id, part_of_speech) VALUES (?, ?, ?)',
        [1, 1, CatalogPartOfSpeech.noun.wireValue],
      );

      final firstPage = await repository.fetchPage(RankingQuery(
        page: 0,
        size: 1,
        accountId: 'account-a',
        includedPartOfSpeech: {CatalogPartOfSpeech.noun},
      ));
      final secondPage = await repository.fetchPage(RankingQuery(
        page: 1,
        size: 1,
        accountId: 'account-a',
        includedPartOfSpeech: {CatalogPartOfSpeech.noun},
      ));

      expect(firstPage.dataOrNull?.items.single.rankedWord, 'first noun');
      expect(firstPage.dataOrNull?.hasNext, isTrue);
      expect(secondPage.dataOrNull?.items.single.rankedWord, 'second noun');
      expect(secondPage.dataOrNull?.hasNext, isFalse);
    });

    test('defensively skips nullable projection rows without failing the page',
        () async {
      final defensiveRepository = DriftRankingQueryRepository(
        _StubRankingDao(database, const [
          RankingQueryRow(
            rankingId: 1,
            rank: 1,
            rankedWord: null,
            lemma: 'invalid',
            wordId: 1,
            hasConjugation: false,
          ),
          RankingQueryRow(
            rankingId: 2,
            rank: 2,
            rankedWord: 'valid',
            lemma: 'valid',
            wordId: 2,
            hasConjugation: false,
          ),
        ]),
      );

      final result = await defensiveRepository.fetchPage(RankingQuery(
        page: 0,
        size: 10,
        accountId: 'account-a',
      ));

      expect(result.isSuccess, isTrue);
      expect(
          result.dataOrNull?.items.map((item) => item.rankedWord), ['valid']);
      expect(result.dataOrNull?.hasNext, isFalse);
    });

    test('still reports database query exceptions as failures', () async {
      final failingRepository =
          DriftRankingQueryRepository(_ThrowingRankingDao(database));

      final result = await failingRepository.fetchPage(RankingQuery(
        page: 0,
        size: 10,
        accountId: 'account-a',
      ));

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.originalError, isA<StateError>());
    });
  });
}

class _StubRankingDao extends RankingDao {
  _StubRankingDao(super.database, this.rows);

  final List<RankingQueryRow> rows;

  @override
  Future<List<RankingQueryRow>> fetchRankingQueryPage(
          RankingQuery query) async =>
      rows;
}

class _ThrowingRankingDao extends RankingDao {
  _ThrowingRankingDao(super.database);

  @override
  Future<List<RankingQueryRow>> fetchRankingQueryPage(RankingQuery query) =>
      Future.error(StateError('query failed'));
}

Future<void> _seed(DatabaseProvider database) async {
  await database.customStatement('''
    INSERT INTO words (word_id, word) VALUES
      (1, 'uno'), (2, 'dos'), (3, 'tres')
  ''');
  await database.customStatement('''
    INSERT INTO rankings (ranking_id, ranking_no, word, word_origin, word_id)
    VALUES
      (1, 1, 'uno', 'uno', 1),
      (2, 2, 'dos', 'dos', 2),
      (3, 3, 'tres', 'tres', 3),
      (4, 4, 'uno variante', 'uno', 1)
  ''');
  await database.customStatement('''
    INSERT INTO word_status
      (word_id, is_learned, edit_at, account_id, local_revision)
    VALUES
      (1, 1, 'now', 'account-a', 0),
      (2, 1, 'now', 'account-b', 0)
  ''');
}
