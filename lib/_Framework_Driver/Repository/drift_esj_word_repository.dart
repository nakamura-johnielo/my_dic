import 'dart:developer';

import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/word/word.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/word/word_status.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_word_repository.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/word_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/word_status_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/database_provider.dart'
    as db;

class DriftEsjWordRepository implements IEsjWordRepository {
  final WordDao _wordDao;
  final WordStatusDao _wordStatusDao;
  //final PartOfSpeechListDao _pslDao;
  DriftEsjWordRepository(this._wordDao, this._wordStatusDao);

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

  @override
  void updateStatus(UpdateStatusRepositoryInputData input) async {
    log("updatestatusrepo");
    db.WordStatusData data = db.WordStatusData(
      wordId: input.wordId,
      isLearned: input.status.contains(FeatureTag.isLearned) ? 1 : 0,
      isBookmarked: input.status.contains(FeatureTag.isBookmarked) ? 1 : 0,
      hasNote: input.status.contains(FeatureTag.hasNote) ? 1 : 0,
      editAt: input.editAt,
    );

    if (await _wordStatusDao.exist(input.wordId)) {
      _wordStatusDao.updateStatus(data);
      return;
    }
    _wordStatusDao.insertStatus(data);
  }

  @override
  Future<List<Word>> getWordsByWordByPage(
      String word, int size, int currentPage, bool forQuiz) async {
    final words = await _wordDao.getWordsByWordByPage(word, size, currentPage);
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

  @override //!TODO delete
  Future<List<Word>> getQuizWordsByWordByPage(
      String word, int size, int currentPage) async {
//nashi
    final words = await _wordDao.getWordsByWordByPage(word, size, currentPage);
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

  @override
  Future<WordStatus> getStatusById(int wordId) async {
    final status = await _wordStatusDao.getStatusById(wordId);
    return WordStatus(
      //wordId: status?.wordId ?? wordId,
      isLearned: status?.isLearned == 1,
      isBookmarked: status?.isBookmarked == 1,
      hasNote: status?.hasNote == 1,
      //editAt: status?.editAt,
    );
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
    (e) => e.display == value,
    orElse: () => PartOfSpeech.none,
  );
}
