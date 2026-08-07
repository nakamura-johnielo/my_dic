import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/features/ranking/application/query/ranking_query.dart';
import 'package:my_dic/features/ranking/data/data_source/local/ranking_dao.dart';
import 'package:my_dic/features/ranking/data/query/drift_ranking_query_repository.dart';

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

      expect(
          accountAIncluded.dataOrNull?.items.map((item) => item.wordId),
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
  });
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
