import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/esj_dictionary.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_dictionary_repository.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/dictionary_dao.dart';

class DriftEsjDictionaryRepository implements IEsjDictionaryRepository {
  final DictionaryDao _dictionaryDao;
  DriftEsjDictionaryRepository(this._dictionaryDao);

  @override
  Future<EsjDictionary?> getDictionaryByWordId(int wordId) async {
    final result = await _dictionaryDao.getDictionaryByWordId(wordId);
    if (result == null) {
      return null; // 結果がnullの場合はnullを返す
    }

    return EsjDictionary(
      dictionaryId: result.dictionaryId,
      word: result.word,
      headword: result.headword,
      content: result.content,

      origin: result.origin,
      //examples:result.examples   ,
      //idioms:result.idioms   ,
      //supplements:result.supplements   ,
    );
  }
}
