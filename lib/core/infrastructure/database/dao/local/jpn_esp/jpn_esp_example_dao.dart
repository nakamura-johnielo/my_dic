import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/table/jpn-esp/jpn_esp_examples.dart';
import 'package:my_dic/core/infrastructure/database/database_provider.dart';

part '../../../../../../__generated/core/infrastructure/database/dao/local/jpn_esp/jpn_esp_example_dao.g.dart';

@DriftAccessor(tables: [JpnEspExamples])
class JpnEspExampleDao extends DatabaseAccessor<DatabaseProvider>
    with _$JpnEspExampleDaoMixin {
  JpnEspExampleDao(super.database);
  Future<List<JpnEspExample?>> getExampleByDictionaryId(int id) {
    return (select(jpnEspExamples)
          ..where((tbl) => tbl.dictionaryId.equals(id))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.exampleId)]))
        .get();
  }
}
