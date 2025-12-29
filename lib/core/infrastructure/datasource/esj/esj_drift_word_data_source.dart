import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';

import 'i_esj_word_data_source.dart';

class EsjDriftWordDataSource implements IEsjWordLocalDataSource {
  final EspJpnWordDao _dao;
  final EspJpnWordStatusDao _statusDao;
  EsjDriftWordDataSource(this._dao, this._statusDao);

  @override
  Future<List<EspJpnWord>> getWordsByWord(String word) async {
     final words = await _dao.getWordsByWord(word);
      if (words == null) return [];
      
      return words.map((word) {
        return EspJpnWord(
          wordId: word.wordId,
          word: word.word,
          partOfSpeech: _convertPartOfSpeech(word.partOfSpeech),
        );
      }).toList();
  }

  @override
  Future<void> updateStatus(UpdateStatusRepositoryInputData input) async {
    final data = EspJpnWordStatusTableData(
      wordId: input.wordId,
      isLearned: input.status.contains(FeatureTag.isLearned) ? 1 : 0,
      isBookmarked: input.status.contains(FeatureTag.isBookmarked) ? 1 : 0,
      hasNote: input.status.contains(FeatureTag.hasNote) ? 1 : 0,
      editAt: input.editAt,
    );
    if (await _statusDao.exist(input.wordId)) {
      await _statusDao.updateStatus(data);
    } else {
      await _statusDao.insertStatus(data);
    }
  }

  @override
  Future<List<EspJpnWord>> getWordsByWordByPage(
      String word, int size, int currentPage, bool forQuiz) async {
    final words = await _dao.getWordsByWordByPage(word, size, currentPage);
    if (words == null) return [];

    return words.map((word) {
      return EspJpnWord(
        wordId: word.wordId,
        word: word.word,
        partOfSpeech: _convertPartOfSpeech(word.partOfSpeech),
      );
    }).toList();
  }

  @override
  Future<List<EspJpnWord>> getQuizWordsByWordByPage(
      String word, int size, int currentPage) async {
    final words = await _dao.getWordsByWordByPage(word, size, currentPage);
    if (words == null) return [];

    return words.map((word) {
      return EspJpnWord(
        wordId: word.wordId,
        word: word.word,
        partOfSpeech: _convertPartOfSpeech(word.partOfSpeech),
      );
    }).toList();
  }

  List<PartOfSpeech> _convertPartOfSpeech(String? data) {
  if (data != null) {
    List<PartOfSpeech> res =
        data.split(',').map((str) => _fromString(str)).toList();
    return res;
  }
  return [PartOfSpeech.none];
}

PartOfSpeech _fromString(String value) {
  return PartOfSpeech.values.firstWhere(
    (e) => e.display == value,
    orElse: () => PartOfSpeech.none,
  );
}

}

