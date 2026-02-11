import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

abstract class ILocalJpnEspWordStatusDataSource {
  Future<JpnEspWordStatusTableData?> getWordStatusById(int id);
  Future<List<JpnEspWordStatusTableData>> getWordStatusAfter(DateTime datetime);
  Future<void> updateWordStatus(
    int wordId,
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    String editAt,
  );
  Stream<JpnEspWordStatusTableData?> watchWordStatusById(int id);
  Stream<List<int>> watchChangedIds(DateTime datetime);
}
