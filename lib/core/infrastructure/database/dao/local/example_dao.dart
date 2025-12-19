import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/table/examples.dart';
import 'package:my_dic/core/infrastructure/database/database_provider.dart';
part '../../../../../__generated/core/infrastructure/database/dao/local/example_dao.g.dart';

@DriftAccessor(tables: [Examples])
class ExampleDao extends DatabaseAccessor<DatabaseProvider>
    with _$ExampleDaoMixin {
  ExampleDao(super.database);

  Future<ExampleTableData?> getExampleById(int id) {
    return (select(examples)..where((tbl) => tbl.exampleId.equals(id)))
        .getSingleOrNull();
  }

  Future<List<ExampleTableData?>> getExampleByDictionaryId(int id) {
    return (select(examples)
          ..where((tbl) => tbl.dictionaryId.equals(id))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.exampleId)]))
        .get();
  }

  Future<void> insertExample(Insertable<ExampleTableData> tableName) =>
      into(examples).insert(tableName);

  Future<void> updateExample(Insertable<ExampleTableData> tableName) =>
      update(examples).replace(tableName);

  Future<void> deleteExample(Insertable<ExampleTableData> tableName) =>
      delete(examples).delete(tableName);
}
