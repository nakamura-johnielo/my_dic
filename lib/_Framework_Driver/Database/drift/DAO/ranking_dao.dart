import 'package:drift/drift.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/rankings.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/database_provider.dart';
part '../../../../__generated/_Framework_Driver/Database/drift/DAO/ranking_dao.g.dart';

@DriftAccessor(tables: [Rankings])
class RankingDao extends DatabaseAccessor<DatabaseProvider>
    with _$RankingDaoMixin {
  RankingDao(super.database);

  Future<Ranking?> getRankingById(int id) {
    return (select(rankings)..where((tbl) => tbl.rankingId.equals(id)))
        .getSingleOrNull();
  }

  Future<void> insertRanking(Insertable<Ranking> tableName) =>
      into(rankings).insert(tableName);

  Future<void> updateRanking(Insertable<Ranking> tableName) =>
      update(rankings).replace(tableName);

  Future<void> deleteRanking(Insertable<Ranking> tableName) =>
      delete(rankings).delete(tableName);
}
