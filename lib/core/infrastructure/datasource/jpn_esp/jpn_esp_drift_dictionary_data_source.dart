import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_dictionary_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_example_dao.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp/jpn_esp_dictionary_dataset.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_repository_input_data.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

import 'i_jpn_esp_dictionary_data_source.dart';

class JpnEspDriftDictionaryDataSource implements IJpnEspDictionaryLocalDataSource {
  final JpnEspDictionaryDao _dictionaryDao;
  final JpnEspExampleDao _exampleDao;

  JpnEspDriftDictionaryDataSource(this._dictionaryDao, this._exampleDao);

  @override
  Future<List<JpnEspDictionaryDataSet>> getDictionaryByWordId(FetchJpnEspDictionaryRepositoryInputData input) async {
    final dic = await _dictionaryDao.getDictionaryByWordId(input.id);
    if (dic.isEmpty) return [];
    final res = <JpnEspDictionaryDataSet>[];
    for (final d in dic) {
      final examples = await _exampleDao.getExampleByDictionaryId(d.dictionaryId);
      res.add(JpnEspDictionaryDataSet(
        dictionary: d,
        examples: examples,
      ));
    }
    return res;
  }
}
