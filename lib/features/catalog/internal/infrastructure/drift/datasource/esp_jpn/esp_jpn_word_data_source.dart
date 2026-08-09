import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

abstract class IEsjWordLocalDataSource {
  Future<List<EspJpnWordTableData>> getWordsByWord(String word);
  Future<List<EspJpnWordTableData>> getWordsByWordByPage(
    String word,
    int size,
    int currentPage,
    bool forQuiz,
  );
  Future<List<EspJpnWordTableData>> getQuizWordsByWordByPage(
    String word,
    int size,
    int currentPage,
  );
}
