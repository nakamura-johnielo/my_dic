import 'package:drift/drift.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/conjugations.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/database_provider.dart';
part '../../../../__generated/_Framework_Driver/Database/drift/DAO/conjugation_dao.g.dart';

@DriftAccessor(tables: [Conjugations])
class ConjugationDao extends DatabaseAccessor<DatabaseProvider>
    with _$ConjugationDaoMixin {
  ConjugationDao(super.database);

  Future<Conjugation?> getConjugationById(int id) {
    return (select(conjugations)..where((tbl) => tbl.wordId.equals(id)))
        .getSingleOrNull();
  }

  Future<void> insertConjugation(Insertable<Conjugation> tableName) =>
      into(conjugations).insert(tableName);

  Future<void> updateConjugation(Insertable<Conjugation> tableName) =>
      update(conjugations).replace(tableName);

  Future<void> deleteConjugation(Insertable<Conjugation> tableName) =>
      delete(conjugations).delete(tableName);
}
