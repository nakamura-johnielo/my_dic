import 'dart:developer';

import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_word_repository.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

class DriftEsjWordRepository implements IEsjWordRepository {
  final EspJpnWordDao _wordDao;
  final EspJpnWordStatusDao _wordStatusDao;
  //final PartOfSpeechListDao _pslDao;
  DriftEsjWordRepository(this._wordDao, this._wordStatusDao);

  @override
  Future<Result<List<EspJpnWord>>> getWordsByWord(String word) async {
    try {
      final words = await _wordDao.getWordsByWord(word);
      if (words == null) return const Result.success([]);
      
      final wordList = words.map((word) {
        return EspJpnWord(
          wordId: word.wordId,
          word: word.word,
          partOfSpeech: _convertPartOfSpeech(word.partOfSpeech),
        );
      }).toList();
      
      return Result.success(wordList);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語の検索に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> updateStatus(UpdateStatusRepositoryInputData input) async {
    try {
      log("updatestatusrepo");
      EspJpnWordStatusTableData data = EspJpnWordStatusTableData(
        wordId: input.wordId,
        isLearned: input.status.contains(FeatureTag.isLearned) ? 1 : 0,
        isBookmarked: input.status.contains(FeatureTag.isBookmarked) ? 1 : 0,
        hasNote: input.status.contains(FeatureTag.hasNote) ? 1 : 0,
        editAt: input.editAt,
      );

      if (await _wordStatusDao.exist(input.wordId)) {
        await _wordStatusDao.updateStatus(data);
      } else {
        await _wordStatusDao.insertStatus(data);
      }
      return const Result.success(null);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語ステータスの更新に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<List<EspJpnWord>>> getWordsByWordByPage(
      String word, int size, int currentPage, bool forQuiz) async {
    try {
      print(word + " , " + size.toString() + " , " + currentPage.toString());
      final words = await _wordDao.getWordsByWordByPage(word, size, currentPage);
      if (words == null) return const Result.success([]);
      
      print("words length in repo: " + words.length.toString());
      final wordList = words.map((word) {
        return EspJpnWord(
          wordId: word.wordId,
          word: word.word,
          partOfSpeech: _convertPartOfSpeech(word.partOfSpeech),
        );
      }).toList();
      
      return Result.success(wordList);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語リストの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override //!TODO delete
  Future<Result<List<EspJpnWord>>> getQuizWordsByWordByPage(
      String word, int size, int currentPage) async {
    try {
      final words = await _wordDao.getWordsByWordByPage(word, size, currentPage);
      if (words == null) return const Result.success([]);
      
      final wordList = words.map((word) {
        return EspJpnWord(
          wordId: word.wordId,
          word: word.word,
          partOfSpeech: _convertPartOfSpeech(word.partOfSpeech),
        );
      }).toList();
      
      return Result.success(wordList);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'クイズ用単語リストの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<WordStatus>> getStatusById(int wordId) async {
    try {
      final status = await _wordStatusDao.getStatusById(wordId);
      return Result.success(WordStatus(
        wordId: wordId,
        isLearned: status?.isLearned == 1,
        isBookmarked: status?.isBookmarked == 1,
        hasNote: status?.hasNote == 1,
        editAt: status?.editAt != null ? DateTime.parse(status!.editAt) : null,
      ));
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語ステータスの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
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
