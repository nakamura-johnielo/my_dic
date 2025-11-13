import 'package:drift/drift.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/es_en_conjugacions.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/database_provider.dart';
part '../../../../__generated/_Framework_Driver/Database/drift/DAO/es_en_conjugacion_dao.g.dart';

@DriftAccessor(tables: [EsEnConjugacions])
class EsEnConjugacionDao extends DatabaseAccessor<DatabaseProvider>
    with _$EsEnConjugacionDaoMixin {
  EsEnConjugacionDao(super.database);

  Future<EsEnConjugacion?> getEnglishConjById(int id) {
    return (select(esEnConjugacions)..where((tbl) => tbl.wordId.equals(id)))
        .getSingleOrNull();
  }
}
