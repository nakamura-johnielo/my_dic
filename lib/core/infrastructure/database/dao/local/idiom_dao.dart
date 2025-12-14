import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/table/idioms.dart';
import 'package:my_dic/core/infrastructure/database/database_provider.dart';
part '../../../../../__generated/core/infrastructure/database/dao/local/idiom_dao.g.dart';

@DriftAccessor(tables: [Idioms])
class IdiomDao extends DatabaseAccessor<DatabaseProvider> with _$IdiomDaoMixin {
  IdiomDao(super.database);

  Future<Idiom?> getIdiomById(int id) {
    return (select(idioms)..where((tbl) => tbl.idiomId.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Idiom?>> getExampleByDictionaryId(int id) {
    return (select(idioms)
          ..where((tbl) => tbl.dictionaryId.equals(id))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.idiomId)]))
        .get();
  }

  Future<void> insertIdiom(Insertable<Idiom> tableName) =>
      into(idioms).insert(tableName);

  Future<void> updateIdiom(Insertable<Idiom> tableName) =>
      update(idioms).replace(tableName);

  Future<void> deleteIdiom(Insertable<Idiom> tableName) =>
      delete(idioms).delete(tableName);
}
