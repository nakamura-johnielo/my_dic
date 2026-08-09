import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/jpn_esp/jpn_esp_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_word_data_source.dart';

class JpnEspDriftWordDataSource implements IJpnEspWordLocalDataSource {
  JpnEspDriftWordDataSource(this._dao);
  final JpnEspWordDao _dao;

  @override
  Future<List<JpnEspWordTableData>> getWordsByWord(
    String word,
    int size,
    int currentPage,
  ) =>
      _dao.getWordsByWord(word, size, currentPage);
}
