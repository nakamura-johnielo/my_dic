import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart' as db;

abstract class IMyWordLocalDataSource {
  Future<MyWord?> getMyWordById(int id);

  Future<List<MyWord>?> getFilteredMyWordByPage(int size, int offset);

  Future<int> insertMyWord(String headword, String description, String dateTime);

  Future<int> deleteMyword(int wordId, String editAt);

  Future<int> updateMyWord(int id, String word, String contents, String dateTime);

  Future<void> updateStatus(db.MyWordStatusTableData data);

  Future<void> insertStatus(db.MyWordStatusTableData data);

  Future<bool> existStatus(int id);
}
