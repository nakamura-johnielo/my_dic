import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

abstract class ILocalWordStatusDataSource {
  Future<EspJpnWordStatusTableData?> getWordStatusById(int id);
  Future<List<EspJpnWordStatusTableData>> getWordStatusAfter(DateTime datetime);
  Future<void> updateWordStatus(EspJpnWordStatusTableData wordStatus);
  Stream<EspJpnWordStatusTableData?> watchWordStatusById(int id);
  Stream<List<int>> watchChangedIds(DateTime datetime);
}
