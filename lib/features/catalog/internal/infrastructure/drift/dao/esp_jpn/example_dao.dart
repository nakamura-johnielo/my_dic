import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/examples.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

part '../../../../../../../__generated/features/catalog/internal/infrastructure/drift/dao/esp_jpn/example_dao.g.dart';

@DriftAccessor(tables: [EspJpnExamples])
class EspJpnExampleDao extends DatabaseAccessor<DatabaseProvider>
    with _$EspJpnExampleDaoMixin {
  EspJpnExampleDao(super.database);

  Future<EspJpnExampleTableData?> getExampleById(int id) {
    return (select(espJpnExamples)..where((tbl) => tbl.exampleId.equals(id)))
        .getSingleOrNull();
  }

  Future<List<EspJpnExampleTableData>> getExampleByDictionaryId(int id) {
    return (select(espJpnExamples)
          ..where((tbl) => tbl.dictionaryId.equals(id))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.exampleId)]))
        .get();
  }
}
