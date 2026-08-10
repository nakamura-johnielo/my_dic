import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/part_of_speech_lists.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

part '../../../../../../../__generated/features/catalog/internal/infrastructure/drift/dao/esp_jpn/part_of_speech_list_dao.g.dart';

@DriftAccessor(tables: [PartOfSpeechLists])
class PartOfSpeechListDao extends DatabaseAccessor<DatabaseProvider>
    with _$PartOfSpeechListDaoMixin {
  PartOfSpeechListDao(super.database);

  Future<List<String>> getPartOfSpeechListByWordId(int id) {
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

}
