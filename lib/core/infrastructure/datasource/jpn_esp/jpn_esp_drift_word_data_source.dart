import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
    as drift;

import 'i_jpn_esp_word_data_source.dart';

class JpnEspDriftWordDataSource implements IJpnEspWordLocalDataSource {
  final JpnEspWordDao _dao;
  JpnEspDriftWordDataSource(this._dao);

  @override
  Future<List<drift.JpnEspWordTableData>> getWordsByWord(
      String word, int size, int currentPage) async {
    final rows = await _dao.getWordsByWord(word, size, currentPage);

    return rows;
  }
}
