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
import 'package:my_dic/core/infrastructure/datasource/esj/i_esj_word_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart';

class EsjWordRepository implements IEsjWordRepository {
  final IEsjWordLocalDataSource _wordDataSource;
  final ILocalWordStatusDataSource _wordStatusDataSource;
  EsjWordRepository(this._wordDataSource, this._wordStatusDataSource);

  @override
  Future<Result<List<EspJpnWord>>> getWordsByWord(String word) async {
    try {
      final words = await _wordDataSource.getWordsByWord(word);
      if (words.isEmpty) return const Result.success([]);
      return Result.success(words);
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
      await _wordDataSource.updateStatus(input);
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
      final words = await _wordDataSource.getWordsByWordByPage(word, size, currentPage, forQuiz);
      if (words.isEmpty) return const Result.success([]);
      return Result.success(words);
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
      final words = await _wordDataSource.getQuizWordsByWordByPage(word, size, currentPage);
      if (words.isEmpty) return const Result.success([]);
      return Result.success(words);
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
      final status = await _wordStatusDataSource.getWordStatusById(wordId);
      return Result.success(status);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語ステータスの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }
}
