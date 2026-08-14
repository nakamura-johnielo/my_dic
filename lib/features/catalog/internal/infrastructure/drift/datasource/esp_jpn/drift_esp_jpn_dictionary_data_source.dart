import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/dictionary_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/example_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/idiom_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/supplement_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_dataset.dart';

class EspJpnDictionaryDriftDataSource implements EspJpnDictionaryDataSource {
  EspJpnDictionaryDriftDataSource(
    this._dictionaryDao,
    this._exampleDao,
    this._idiomDao,
    this._supplementDao,
  );

  final EspjpnDictionaryDao _dictionaryDao;
  final EspJpnExampleDao _exampleDao;
  final EspJpnIdiomDao _idiomDao;
  final EspJpnSupplementDao _supplementDao;

  @override
  Future<List<EspJpnDictionaryDataSet>> getDictionaryByWordId(
      int wordId) async {
    final dictionaries = await _dictionaryDao.getDictionaryByWordId(wordId);
    final result = <EspJpnDictionaryDataSet>[];
    for (final dictionary in dictionaries) {
      final dictionaryId = dictionary.dictionaryId;
      result.add(EspJpnDictionaryDataSet(
        dictionary: dictionary,
        examples: await _exampleDao.getExampleByDictionaryId(dictionaryId),
        idioms: await _idiomDao.getExampleByDictionaryId(dictionaryId),
        supplements:
            await _supplementDao.getExampleByDictionaryId(dictionaryId),
      ));
    }
    return result;
  }

}
