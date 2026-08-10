import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/features/ranking/internal/infrastructure/drift/drift_ranking_query_repository.dart';
import 'package:my_dic/features/ranking/internal/infrastructure/drift/ranking_dao.dart';
import 'package:my_dic/features/ranking/port/model/ranking_query.dart';

void main() {
  late DatabaseProvider database;
  late DriftRankingQueryRepository repository;

  setUp(() async {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
    repository = DriftRankingQueryRepository(RankingDao(database));
    await database.customStatement('''
      INSERT INTO words (word_id, word) VALUES (1, 'uno'), (2, 'dos')
    ''');
    await database.customStatement('''
      INSERT INTO rankings (ranking_id, ranking_no, word, word_origin, word_id)
      VALUES
        (10, 1, 'uno', 'uno', 1),
        (11, 2, 'uno variante', 'uno', 1),
        (20, 3, 'dos', 'dos', 2)
    ''');
  });

  tearDown(() => database.close());

  test('propagates rankingId and preserves rows sharing one wordId', () async {
    final page = await repository.fetchPage(RankingQuery(
      page: 0,
      size: 10,
      accountId: 'account-a',
    ));

    expect(page.dataOrNull?.items.map((item) => item.rankingId), [10, 11, 20]);
    expect(page.dataOrNull?.items.map((item) => item.wordId), [1, 1, 2]);
  });

  test('multiLemma groups by wordId with MIN(ranking_id) as stable identity',
      () async {
    final page = await repository.fetchPage(RankingQuery(
      page: 0,
      size: 10,
      accountId: 'account-a',
      includedFeatureTags: {FeatureTag.multiLemma},
    ));

    expect(page.dataOrNull?.items.map((item) => item.wordId), [1, 2]);
    expect(page.dataOrNull?.items.map((item) => item.rankingId), [10, 20]);
  });
}
