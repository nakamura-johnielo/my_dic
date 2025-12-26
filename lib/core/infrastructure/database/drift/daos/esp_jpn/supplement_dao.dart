import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/supplements.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

part '../../../../../../__generated/core/infrastructure/database/drift/daos/esp_jpn/supplement_dao.g.dart';

@DriftAccessor(tables: [EspJpnSupplements])
class EspJpnSupplementDao extends DatabaseAccessor<DatabaseProvider>
    with _$EspJpnSupplementDaoMixin {
  EspJpnSupplementDao(super.database);

  Future<EspJpnSupplementTableData?> getSupplementById(int id) {
    return (select(espJpnSupplements)..where((tbl) => tbl.supplementId.equals(id)))
        .getSingleOrNull();
  }

  Future<List<EspJpnSupplementTableData?>> getExampleByDictionaryId(int id) {
    return (select(espJpnSupplements)
          ..where((tbl) => tbl.dictionaryId.equals(id))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.supplementId)]))
        .get();
  }

  Future<void> insertSupplement(Insertable<EspJpnSupplementTableData> tableName) =>
      into(espJpnSupplements).insert(tableName);

  Future<void> updateSupplement(Insertable<EspJpnSupplementTableData> tableName) =>
      update(espJpnSupplements).replace(tableName);

  Future<void> deleteSupplement(Insertable<EspJpnSupplementTableData> tableName) =>
      delete(espJpnSupplements).delete(tableName);
}
