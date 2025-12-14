import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/table/supplements.dart';
import 'package:my_dic/core/infrastructure/database/database_provider.dart';
part '../../../../../__generated/core/infrastructure/database/dao/local/supplement_dao.g.dart';

@DriftAccessor(tables: [Supplements])
class SupplementDao extends DatabaseAccessor<DatabaseProvider>
    with _$SupplementDaoMixin {
  SupplementDao(super.database);

  Future<Supplement?> getSupplementById(int id) {
    return (select(supplements)..where((tbl) => tbl.supplementId.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Supplement?>> getExampleByDictionaryId(int id) {
    return (select(supplements)
          ..where((tbl) => tbl.dictionaryId.equals(id))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.supplementId)]))
        .get();
  }

  Future<void> insertSupplement(Insertable<Supplement> tableName) =>
      into(supplements).insert(tableName);

  Future<void> updateSupplement(Insertable<Supplement> tableName) =>
      update(supplements).replace(tableName);

  Future<void> deleteSupplement(Insertable<Supplement> tableName) =>
      delete(supplements).delete(tableName);
}
