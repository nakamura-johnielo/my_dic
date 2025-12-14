import 'package:drift/drift.dart';
import 'package:my_dic/_Framework_Driver/local/drift/Entity/part_of_speech_lists.dart';
import 'package:my_dic/core/infrastructure/database/database_provider.dart';
part '../../../../__generated/_Framework_Driver/Database/drift/DAO/part_of_speech_list_dao.g.dart';

@DriftAccessor(tables: [PartOfSpeechLists])
class PartOfSpeechListDao extends DatabaseAccessor<DatabaseProvider>
    with _$PartOfSpeechListDaoMixin {
  PartOfSpeechListDao(super.database);

  Future<List<String>?> getPartOfSpeechListByWordId(int id) {
    return (select(partOfSpeechLists)
          ..addColumns([partOfSpeechLists.partOfSpeech])
          ..where((tbl) => tbl.wordId.equals(id)))
        .map((row) => row.partOfSpeech)
        .get();
  }

  Future<PartOfSpeechList?> getPartOfSpeechListById(int id) {
    return (select(partOfSpeechLists)..where((tbl) => tbl.wordId.equals(id)))
        .getSingleOrNull();
  }

  Future<void> insertPartOfSpeechList(Insertable<PartOfSpeechList> tableName) =>
      into(partOfSpeechLists).insert(tableName);

  Future<void> updatePartOfSpeechList(Insertable<PartOfSpeechList> tableName) =>
      update(partOfSpeechLists).replace(tableName);

  Future<void> deletePartOfSpeechList(Insertable<PartOfSpeechList> tableName) =>
      delete(partOfSpeechLists).delete(tableName);
}
