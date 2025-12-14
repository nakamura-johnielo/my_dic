import 'package:my_dic/core/domain/entity/jpn_esp/example/jpn_esp_example.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_repository_input_data.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/jpn_esp/jpn_esp_dictionary_dao.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/jpn_esp/jpn_esp_example_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/database_provider.dart'
    as drift;

class DriftJpnEspDictionaryRepository implements IJpnEspDictionaryRepository {
  final JpnEspDictionaryDao _dictionaryDao;
  final JpnEspExampleDao _exampleDao;

  DriftJpnEspDictionaryRepository(this._dictionaryDao, this._exampleDao);

  @override
  Future<List<JpnEspDictionary>> getDictionaryByWordId(
      FetchJpnEspDictionaryRepositoryInputData input) async {
    final dic = await _dictionaryDao.getDictionaryByWordId(input.id);
    List<JpnEspDictionary> res = [];
    if (dic.isEmpty) {
      return res; // 結果がnullの場合はnullを返す
    }

    for (int i = 0; i < dic.length; i++) {
      final d = dic[i];
      final int dicId = d.dictionaryId;
      final exp = await _exampleDao.getExampleByDictionaryId(dicId);

      res.add(JpnEspDictionary(
        id: d.dictionaryId,
        wordId: d.wordId,
        word: d.word,
        headword: d.headword,
        content: d.htmlRaw, //!todo
        examples: (exp.isNotEmpty) ? convertExamples(exp) : null,
      ));
    }

    return res;
  }
}

List<JpnEspExampleWith>? convertExamples(
    List<drift.JpnEspExample?> exampleList) {
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
