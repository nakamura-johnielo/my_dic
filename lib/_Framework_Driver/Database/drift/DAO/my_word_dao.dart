import 'package:drift/drift.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/my_words.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/database_provider.dart';
part '../../../../__generated/_Framework_Driver/Database/drift/DAO/my_word_dao.g.dart';

@DriftAccessor(tables: [MyWords])
class MyWordDao extends DatabaseAccessor<DatabaseProvider>
    with _$MyWordDaoMixin {
  MyWordDao(super.database);

  Future<MyWord?> getMyWordById(int id) {
    return (select(myWords)..where((tbl) => tbl.myWordId.equals(id)))
        .getSingleOrNull();
  }

  Future<void> insertMyWord(Insertable<MyWord> tableName) =>
      into(myWords).insert(tableName);

  Future<void> updateMyWord(Insertable<MyWord> tableName) =>
      update(myWords).replace(tableName);

  Future<void> deleteMyWord(Insertable<MyWord> tableName) =>
      delete(myWords).delete(tableName);
}
