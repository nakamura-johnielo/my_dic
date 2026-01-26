import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart' as db;

abstract class IMyWordLocalDataSource {
  Future<db.MyWordTableData?> getMyWordById(String id);

  Future<List<db.MyWordTableData>?> getFilteredMyWordByPage(int size, int offset);

  Future<List<String>?> getIdsFilteredMyWordByPage(int size, int offset);

  Future<void> insertMyWord(String id, String headword, String description, String dateTime);

  Future<int> deleteMyword(String wordId, String editAt);

  Future<int> updateMyWord(String id, String word, String contents, String dateTime);

  Future<List<db.MyWordTableData>> getMyWordsAfter(String dateTime);

  Stream<List<String>> watchMyWordIdsAfter(String dateTime);
  Stream<db.MyWordTableData?> streamMyWordById(String id);
}
