import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/idioms.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
part '../../../../../../../__generated/features/catalog/internal/infrastructure/drift/dao/esp_jpn/idiom_dao.g.dart';

@DriftAccessor(tables: [EspJpnIdioms])
class EspJpnIdiomDao extends DatabaseAccessor<DatabaseProvider>
    with _$EspJpnIdiomDaoMixin {
  EspJpnIdiomDao(super.database);

  Future<EspJpnIdiomTableData?> getIdiomById(int id) {
    return (select(espJpnIdioms)..where((tbl) => tbl.idiomId.equals(id)))
        .getSingleOrNull();
  }

  Future<List<EspJpnIdiomTableData>> getExampleByDictionaryId(int id) {
    return (select(espJpnIdioms)
          ..where((tbl) => tbl.dictionaryId.equals(id))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.idiomId)]))
        .get();
  }

}
