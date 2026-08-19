import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/es_en_conjugacions.dart';

part '../../../../../../__generated/features/quiz/internal/infrastructure/drift/dao/es_en_conjugacion_dao.g.dart';

/// 共有される物理 Es-En 活用形テーブルに対する Quiz 所有のアクセサー。
@DriftAccessor(tables: [EsEnConjugacions])
class EsEnConjugacionDao extends DatabaseAccessor<DatabaseProvider>
    with _$EsEnConjugacionDaoMixin {
  EsEnConjugacionDao(super.database);

  Future<EsEnConjugacionTableData?> getEnglishConjById(int id) {
    return (select(esEnConjugacions)..where((tbl) => tbl.wordId.equals(id)))
        .getSingleOrNull();
  }
}
