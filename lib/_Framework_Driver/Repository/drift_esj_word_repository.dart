import 'package:my_dic/Constants/Enums/part_of_speech.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/word.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_word_repository.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/word_dao.dart';

class DriftEsjWordRepository implements IEsjWordRepository {
  final WordDao _wordDao;
  DriftEsjWordRepository(this._wordDao);

  @override
  Future<List<Word>> getWordsByWord(String word) async {
    final words = await _wordDao.getWordsByWord(word);
    if (words == null) return [];
    return words.map((word) {
      return Word(
        wordId: word.wordId,
        word: word.word,
        partOfSpeech: PartOfSpeech.adverb,
      );
    }).toList();
  }
}
