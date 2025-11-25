import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/esj_dictionary.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/sub/example/impl/example.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/sub/idiom/impl/idiom.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/sub/supplement.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_dictionary_repository.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/dictionary_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/example_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/idiom_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/supplement_dao.dart';

class DriftEsjDictionaryRepository implements IEsjDictionaryRepository {
  final DictionaryDao _dictionaryDao;
  final ExampleDao _exampleDao;
  final IdiomDao _idiomDao;
  final SupplementDao _supplementDao;
  DriftEsjDictionaryRepository(this._dictionaryDao, this._exampleDao,
      this._idiomDao, this._supplementDao);

  @override
  Future<List<EsjDictionary>> getDictionaryByWordId(int wordId) async {
    final dic = await _dictionaryDao.getDictionaryByWordId(wordId);
    List<EsjDictionary> res = [];
    if (dic.isEmpty) {
      return res; // 結果がnullの場合はnullを返す
    }

    for (int i = 0; i < dic.length; i++) {
      final d = dic[i];
      final int dicId = d.dictionaryId;
      final exp = await _exampleDao.getExampleByDictionaryId(dicId);
      final idi = await _idiomDao.getExampleByDictionaryId(dicId);
      final sup = await _supplementDao.getExampleByDictionaryId(dicId);

      res.add(EsjDictionary(
        dictionaryId: d.dictionaryId,
        word: d.word,
        headword: d.headword,
        content: d.htmlRaw, //!todo
        origin: d.origin,
        examples: (exp.isNotEmpty) ? convertExamples(exp) : null,
        idioms: idi.isNotEmpty ? convertIdioms(idi) : null,
        supplements: sup.isNotEmpty ? convertSupplements(sup) : null,
      ));
    }

    return res;
  }
}

List<Example>? convertExamples(exampleList) {
  List<Example>? res = [];
  if (exampleList.isEmpty) {
    return res;
  }
  for (int i = 0; i < exampleList.length; i++) {
    res.add(Example(
      exampleId: exampleList[i].exampleId,
      japanese: exampleList[i].japaneseText,
      espanol: exampleList[i].espanolText,
    ));
  }
  /* res = exampleList
      .where((e) => e != null)
      .map((e) => Example(
            exampleId: e.exampleId,
            japanese: e.japaneseText,
            espanol: e.espanolText,
          ))
      .toList(); */
  return res;
}

List<Supplement> convertSupplements(lists) {
  List<Supplement>? res = [];
  if (lists.isEmpty) {
    return res;
  }
  for (int i = 0; i < lists.length; i++) {
    res.add(Supplement(
      supplementId: lists[i].supplementId,
      supplement: lists[i].content,
    ));
  }

  return res;

  /* return lists
      .map((e) =>
          Supplement(supplementId: e.supplementId, supplement: e.content))
      .toList(); */
}

List<Idiom> convertIdioms(lists) {
  List<Idiom>? res = [];
  if (lists.isEmpty) {
    return res;
  }
  for (int i = 0; i < lists.length; i++) {
    res.add(Idiom(
        idiomId: lists[i].idiomId,
        idiom: lists[i].idiom,
        description: lists[i].description));
  }

  return res;

/*   return lists
      .map((e) =>
          Idiom(idiomId: e.idiomId, idiom: e.idiom, description: e.description))
      .toList(); */
}
