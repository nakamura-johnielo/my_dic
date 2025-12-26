import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/entity/dictionary/sub/example/impl/esp_jpn_example.dart';
import 'package:my_dic/core/domain/entity/dictionary/sub/idiom/impl/idiom.dart';
import 'package:my_dic/core/domain/entity/dictionary/sub/supplement.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_dictionary_repository.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/dictionary_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/example_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/idiom_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/supplement_dao.dart';

class DriftEsjDictionaryRepository implements IEsjDictionaryRepository {
  final EspjpnDictionaryDao _dictionaryDao;
  final EspJpnExampleDao _exampleDao;
  final EspJpnIdiomDao _idiomDao;
  final EspJpnSupplementDao _supplementDao;
  DriftEsjDictionaryRepository(this._dictionaryDao, this._exampleDao,
      this._idiomDao, this._supplementDao);

  @override
  Future<Result<List<EspJpnDictionary>>> getDictionaryByWordId(int wordId) async {
    try {
      final dic = await _dictionaryDao.getDictionaryByWordId(wordId);
      List<EspJpnDictionary> res = [];
      if (dic.isEmpty) {
        return Result.failure(NotFoundError(
          message: '辞書データが見つかりません',
        ));
      }

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
          examples: (exp.isNotEmpty) ? convertExamples(exp) : null,
          idioms: idi.isNotEmpty ? convertIdioms(idi) : null,
          supplements: sup.isNotEmpty ? convertSupplements(sup) : null,
        ));
      }

      return Result.success(res);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '辞書データの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }
}

List<EspJpnExample>? convertExamples(exampleList) {
  List<EspJpnExample>? res = [];
  if (exampleList.isEmpty) {
    return res;
  }
  for (int i = 0; i < exampleList.length; i++) {
    res.add(EspJpnExample(
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
