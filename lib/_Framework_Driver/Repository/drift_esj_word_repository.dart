import 'package:my_dic/Constants/Enums/part_of_speech.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/word.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_word_repository.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/part_of_speech_list_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/word_dao.dart';

class DriftEsjWordRepository implements IEsjWordRepository {
  final WordDao _wordDao;
  //final PartOfSpeechListDao _pslDao;
  DriftEsjWordRepository(this._wordDao);

  @override
  Future<List<Word>> getWordsByWord(String word) async {
    final words = await _wordDao.getWordsByWord(word);
    if (words == null) return [];
    //final partOfSpeech=await _pslDao.getPartOfSpeechListByWordId(word)
    return words.map((word) {
      return Word(
        wordId: word.wordId,
        word: word.word,
        partOfSpeech: _convertPartOfSpeech(word.partOfSpeech),
      );
    }).toList();
  }
}

List<PartOfSpeech> _convertPartOfSpeech(String? data) {
  if (data != null) {
    List<PartOfSpeech> res =
        data.split(',').map((str) => _fromString(str)).toList();
    return res;
  }
  //if(res.length==1&&res[0]===PartOfSpeech.none)
  return [PartOfSpeech.none];
}

PartOfSpeech _fromString(String value) {
  return PartOfSpeech.values.firstWhere(
    (e) => e.japName == value,
    orElse: () => PartOfSpeech.none,
  );
}
