import 'package:drift/drift.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/examples.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/database_provider.dart';
part '../../../../__generated/_Framework_Driver/Database/drift/DAO/example_dao.g.dart';

@DriftAccessor(tables: [Examples])
class ExampleDao extends DatabaseAccessor<DatabaseProvider>
    with _$ExampleDaoMixin {
  ExampleDao(super.database);

  Future<Example?> getExampleById(int id) {
    return (select(examples)..where((tbl) => tbl.exampleId.equals(id)))
        .getSingleOrNull();
  }

  Future<void> insertExample(Insertable<Example> tableName) =>
      into(examples).insert(tableName);

  Future<void> updateExample(Insertable<Example> tableName) =>
      update(examples).replace(tableName);

  Future<void> deleteExample(Insertable<Example> tableName) =>
      delete(examples).delete(tableName);
}
