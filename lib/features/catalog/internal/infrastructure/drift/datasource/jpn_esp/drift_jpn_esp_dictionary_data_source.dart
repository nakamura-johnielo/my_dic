import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/jpn_esp/jpn_esp_dictionary_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/jpn_esp/jpn_esp_example_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_dictionary_dataset.dart';

class JpnEspDictionaryDriftDataSource implements JpnEspDictionaryDataSource {
  JpnEspDictionaryDriftDataSource(this._dictionaryDao, this._exampleDao);
  final JpnEspDictionaryDao _dictionaryDao;
  final JpnEspExampleDao _exampleDao;

  @override
  Future<List<JpnEspDictionaryDataSet>> getDictionaryByWordId(
      int wordId) async {
    final dictionaries = await _dictionaryDao.getDictionaryByWordId(wordId);
    final result = <JpnEspDictionaryDataSet>[];
    for (final dictionary in dictionaries) {
      result.add(JpnEspDictionaryDataSet(
        dictionary: dictionary,
        examples:
            await _exampleDao.getExampleByDictionaryId(dictionary.dictionaryId),
      ));
    }
    return result;
  }

}
