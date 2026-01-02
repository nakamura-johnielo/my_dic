import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/dictionary_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/example_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/idiom_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/supplement_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/datasource/esj/esj_dictionary_dataset.dart';

import 'i_esj_dictionary_data_source.dart';

class EsjDriftDictionaryDataSource implements IEsjDictionaryLocalDataSource {
  final EspjpnDictionaryDao _dictionaryDao;
  final EspJpnExampleDao _exampleDao;
  final EspJpnIdiomDao _idiomDao;
  final EspJpnSupplementDao _supplementDao;

  EsjDriftDictionaryDataSource(this._dictionaryDao, this._exampleDao,
      this._idiomDao, this._supplementDao);

  @override
  Future<List<EsjDictionaryDataSet>> getDictionaryByWordId(int wordId) async {
    final dic = await _dictionaryDao.getDictionaryByWordId(wordId);
    List<EsjDictionaryDataSet> res = [];
    if (dic.isEmpty) return res;

    for (int i = 0; i < dic.length; i++) {
      final d = dic[i];
      final int dicId = d.dictionaryId;
      final exp = await _exampleDao.getExampleByDictionaryId(dicId);
      final idi = await _idiomDao.getExampleByDictionaryId(dicId);
      final sup = await _supplementDao.getExampleByDictionaryId(dicId);

      res.add(EsjDictionaryDataSet(
        dictionary: d,
        examples: exp,
        idioms: idi,
        supplements: sup,
      ));
    }

    return res;
  }
}
