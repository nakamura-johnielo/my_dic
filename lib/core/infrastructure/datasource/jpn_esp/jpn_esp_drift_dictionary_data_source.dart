import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_dictionary_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_example_dao.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/example/jpn_esp_example.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_repository_input_data.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

import 'i_jpn_esp_dictionary_data_source.dart';

class JpnEspDriftDictionaryDataSource implements IJpnEspDictionaryLocalDataSource {
  final JpnEspDictionaryDao _dictionaryDao;
  final JpnEspExampleDao _exampleDao;

  JpnEspDriftDictionaryDataSource(this._dictionaryDao, this._exampleDao);

  @override
  Future<List<JpnEspDictionary>> getDictionaryByWordId(FetchJpnEspDictionaryRepositoryInputData input) async {
    final dic = await _dictionaryDao.getDictionaryByWordId(input.id);
    if (dic.isEmpty) return [];
    final res = <JpnEspDictionary>[];
    for (final d in dic) {
      final examples = await _exampleDao.getExampleByDictionaryId(d.dictionaryId);
      res.add(JpnEspDictionary(
        id: d.dictionaryId,
        wordId: d.wordId,
        word: d.word,
        headword: d.headword,
        content: d.htmlRaw,
        examples: (examples.isNotEmpty)
            ?  _convertExamples(examples) : null,
      ));
    }
    return res;
  }
List<JpnEspExampleWith>? _convertExamples(
    List<JpnEspExampleTableData?> exampleList) {
  List<JpnEspExampleWith> res = [];
  if (exampleList.isEmpty) {
    return res;
  }
  for (int i = 0; i < exampleList.length; i++) {
    res.add(JpnEspExampleWith(
      exampleId: exampleList[i]!.exampleId,
      japanese: exampleList[i]!.japaneseText,
      espanol: exampleList[i]!.espanolText,
      espanolHtml: exampleList[i]!.espanolHtml,
    ));
  }
  return res;
}

}
