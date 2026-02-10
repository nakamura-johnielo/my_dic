import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

abstract class IJpnEspWordLocalDataSource {
  Future<List<JpnEspWordTableData>> getWordsByWord(
      String word, int size, int currentPage);
}
