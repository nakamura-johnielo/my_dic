import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/dictionary_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/example_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/idiom_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/supplement_dao.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/entity/dictionary/sub/example/impl/esp_jpn_example.dart';
import 'package:my_dic/core/domain/entity/dictionary/sub/idiom/impl/idiom.dart';
import 'package:my_dic/core/domain/entity/dictionary/sub/supplement.dart';

import 'i_esj_dictionary_data_source.dart';

class EsjDriftDictionaryDataSource implements IEsjDictionaryLocalDataSource {
  final EspjpnDictionaryDao _dictionaryDao;
  final EspJpnExampleDao _exampleDao;
  final EspJpnIdiomDao _idiomDao;
  final EspJpnSupplementDao _supplementDao;

  EsjDriftDictionaryDataSource(this._dictionaryDao, this._exampleDao,
      this._idiomDao, this._supplementDao);

  @override
  Future<List<EspJpnDictionary>> getDictionaryByWordId(int wordId) async {
    final dic = await _dictionaryDao.getDictionaryByWordId(wordId);
    List<EspJpnDictionary> res = [];
    if (dic.isEmpty) return res;

    for (int i = 0; i < dic.length; i++) {
      final d = dic[i];
      final int dicId = d.dictionaryId;
      final exp = await _exampleDao.getExampleByDictionaryId(dicId);
      final idi = await _idiomDao.getExampleByDictionaryId(dicId);
      final sup = await _supplementDao.getExampleByDictionaryId(dicId);

      res.add(EspJpnDictionary(
        dictionaryId: d.dictionaryId,
        word: d.word,
        headword: d.headword,
        content: d.htmlRaw,
        origin: d.origin,
        examples: (exp.isNotEmpty) ? _convertExamples(exp) : null,
        idioms: idi.isNotEmpty ? _convertIdioms(idi) : null,
        supplements: sup.isNotEmpty ? _convertSupplements(sup) : null,
      ));
    }

    return res;
  }

  List<EspJpnExample>? _convertExamples(exampleList) {
    List<EspJpnExample>? res = [];
    if (exampleList.isEmpty) return res;
    for (int i = 0; i < exampleList.length; i++) {
      final e = exampleList[i];
      res.add(EspJpnExample(
        exampleId: e.exampleId,
        japanese: e.japaneseText,
        espanol: e.espanolText,
      ));
    }
    return res;
  }

  List<Supplement> _convertSupplements(lists) {
    List<Supplement> res = [];
    if (lists.isEmpty) return res;
    for (int i = 0; i < lists.length; i++) {
      res.add(Supplement(
        supplementId: lists[i].supplementId,
        supplement: lists[i].content,
      ));
    }
    return res;
  }

  List<Idiom> _convertIdioms(lists) {
    List<Idiom> res = [];
    if (lists.isEmpty) return res;
    for (int i = 0; i < lists.length; i++) {
      res.add(Idiom(
          idiomId: lists[i].idiomId,
          idiom: lists[i].idiom,
          description: lists[i].description));
    }
    return res;
  }
}
