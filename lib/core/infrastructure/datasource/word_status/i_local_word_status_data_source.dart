import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

abstract class ILocalWordStatusDataSource {
  Future<EspJpnWordStatusTableData?> getWordStatusById(int id);
  Future<List<EspJpnWordStatusTableData>> getWordStatusAfter(DateTime datetime);
  Future<void> updateWordStatus(
    int wordId,
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    String editAt,
  );
  Stream<EspJpnWordStatusTableData?> watchWordStatusById(int id);
  Stream<List<int>> watchChangedIds(DateTime datetime);
}
