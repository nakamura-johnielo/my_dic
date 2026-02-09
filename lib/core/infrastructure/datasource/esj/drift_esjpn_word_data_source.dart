import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

import 'i_esj_word_data_source.dart';

class DriftEspJpnWordDataSource implements IEsjWordLocalDataSource {
  final EspJpnWordDao _dao;
  DriftEspJpnWordDataSource(this._dao);

  @override
  Future<List<EspJpnWordTableData>> getWordsByWord(String word) async {
    final words = await _dao.getWordsByWord(word);

    return words;
  }

  @override
  Future<List<EspJpnWordTableData>> getWordsByWordByPage(
      String word, int size, int currentPage, bool forQuiz) async {
    final words = await _dao.getWordsByWordByPage(word, size, currentPage);

    return words;
  }

  @override
  Future<List<EspJpnWordTableData>> getQuizWordsByWordByPage(
      String word, int size, int currentPage) async {
    final words = await _dao.getWordsByWordByPage(word, size, currentPage);

    return words;
  }
}
