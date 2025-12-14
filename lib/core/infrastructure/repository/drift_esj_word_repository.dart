import 'dart:developer';

import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/core/common/enums/word/part_of_speech.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';
import 'package:my_dic/core/domain/entity/word/esp_word.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_word_repository.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/word_dao.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/database_provider.dart'
    as db;

class DriftEsjWordRepository implements IEsjWordRepository {
  final WordDao _wordDao;
  final WordStatusDao _wordStatusDao;
  //final PartOfSpeechListDao _pslDao;
  DriftEsjWordRepository(this._wordDao, this._wordStatusDao);

  @override
  Future<List<EspJpnWord>> getWordsByWord(String word) async {
    final words = await _wordDao.getWordsByWord(word);
    if (words == null) return [];
    //final partOfSpeech=await _pslDao.getPartOfSpeechListByWordId(word)
    return words.map((word) {
      return EspJpnWord(
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
  Future<List<EspJpnWord>> getWordsByWordByPage(
      String word, int size, int currentPage, bool forQuiz) async {
    final words = await _wordDao.getWordsByWordByPage(word, size, currentPage);
    if (words == null) return [];
    //final partOfSpeech=await _pslDao.getPartOfSpeechListByWordId(word)
    return words.map((word) {
      return EspJpnWord(
        wordId: word.wordId,
        word: word.word,
        partOfSpeech: _convertPartOfSpeech(word.partOfSpeech),
      );
    }).toList();
  }

  @override //!TODO delete
  Future<List<EspJpnWord>> getQuizWordsByWordByPage(
      String word, int size, int currentPage) async {
//nashi
    final words = await _wordDao.getWordsByWordByPage(word, size, currentPage);
    if (words == null) return [];
    //final partOfSpeech=await _pslDao.getPartOfSpeechListByWordId(word)
    return words.map((word) {
      return EspJpnWord(
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
      wordId: wordId,
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
