import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

abstract class ILocalJpnEspWordStatusDataSource {
  Future<JpnEspWordStatusTableData?> getWordStatusById(int id);
  Future<List<JpnEspWordStatusTableData>> getWordStatusAfter(DateTime datetime);
  Future<JpnEspWordStatusTableData> updateWordStatus(
    int wordId,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    String editAt,
  );
  Stream<JpnEspWordStatusTableData?> watchWordStatusById(int id);
  Stream<List<int>> watchChangedIds(DateTime datetime);
}
