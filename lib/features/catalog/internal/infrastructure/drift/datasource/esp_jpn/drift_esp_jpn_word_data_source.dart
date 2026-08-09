import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/esp_jpn_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_word_data_source.dart';

class DriftEspJpnWordDataSource implements IEsjWordLocalDataSource {
  DriftEspJpnWordDataSource(this._dao);
  final EspJpnWordDao _dao;

  @override
  Future<List<EspJpnWordTableData>> getWordsByWord(String word) =>
      _dao.getWordsByWord(word);
  @override
  Future<List<EspJpnWordTableData>> getWordsByWordByPage(
    String word,
    int size,
    int currentPage,
    bool forQuiz,
  ) =>
      _dao.getWordsByWordByPage(word, size, currentPage);
  @override
  Future<List<EspJpnWordTableData>> getQuizWordsByWordByPage(
    String word,
    int size,
    int currentPage,
  ) =>
      _dao.getWordsByWordByPage(word, size, currentPage);
}
