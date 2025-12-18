import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/table/es_en_conjugacions.dart';
import 'package:my_dic/core/infrastructure/database/database_provider.dart';
part '../../../../../__generated/core/infrastructure/database/dao/local/es_en_conjugacion_dao.g.dart';

@DriftAccessor(tables: [EsEnConjugacions])
class EsEnConjugacionDao extends DatabaseAccessor<DatabaseProvider>
    with _$EsEnConjugacionDaoMixin {
  EsEnConjugacionDao(super.database);

  Future<EsEnConjugacionTableData?> getEnglishConjById(int id) {
    return (select(esEnConjugacions)..where((tbl) => tbl.wordId.equals(id)))
        .getSingleOrNull();
  }
}
