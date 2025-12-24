import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/table/esp_jpn/examples.dart';
import 'package:my_dic/core/infrastructure/database/database_provider.dart';

part '../../../../../../__generated/core/infrastructure/database/dao/local/esp_jpn/example_dao.g.dart';
@DriftAccessor(tables: [EspJpnExamples])
class EspJpnExampleDao extends DatabaseAccessor<DatabaseProvider>
    with _$EspJpnExampleDaoMixin {
  EspJpnExampleDao(super.database);

  Future<EspJpnExampleTableData?> getExampleById(int id) {
    return (select(espJpnExamples)..where((tbl) => tbl.exampleId.equals(id)))
        .getSingleOrNull();
  }

  Future<List<EspJpnExampleTableData?>> getExampleByDictionaryId(int id) {
    return (select(espJpnExamples)
          ..where((tbl) => tbl.dictionaryId.equals(id))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.exampleId)]))
        .get();
  }

  Future<void> insertExample(Insertable<EspJpnExampleTableData> tableName) =>
      into(espJpnExamples).insert(tableName);

  Future<void> updateExample(Insertable<EspJpnExampleTableData> tableName) =>
      update(espJpnExamples).replace(tableName);

  Future<void> deleteExample(Insertable<EspJpnExampleTableData> tableName) =>
      delete(espJpnExamples).delete(tableName);
}
