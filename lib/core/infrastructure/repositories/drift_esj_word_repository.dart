import 'dart:developer';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_word_repository.dart';
import 'package:my_dic/core/infrastructure/datasource/esj/i_esj_word_data_source.dart';
import 'package:my_dic/core/infrastructure/repositories/converters/esj_word_converter.dart';

class EsjWordRepository implements IEsjWordRepository {
  final IEsjWordLocalDataSource _wordDataSource;
  // final ILocalWordStatusDataSource _wordStatusDataSource;
  EsjWordRepository(this._wordDataSource);

  @override
  Future<Result<List<EspJpnWord>>> getWordsByWord(String word) async {
    try {
      final tableDataList = await _wordDataSource.getWordsByWord(word);
      final entities = EsjWordConverter.toEntityList(tableDataList);
      return Result.success(entities);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語の検索に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  // @override
  // Future<Result<void>> updateStatus(UpdateStatusRepositoryInputData input) async {
  //   try {
  //     log("updatestatusrepo");
  //     await _wordDataSource.updateStatus(input);
  //     return const Result.success(null);
  //   } catch (e, s) {
  //     return Result.failure(DatabaseError(
  //       message: '単語ステータスの更新に失敗しました',
  //       originalError: e,
  //       stackTrace: s,
  //     ));
  //   }
  // }

  @override
  Future<Result<List<EspJpnWord>>> getWordsByWordByPage(
      String word, int size, int currentPage, bool forQuiz) async {
    try {
      final tableDataList = await _wordDataSource.getWordsByWordByPage(word, size, currentPage, forQuiz);
      final entities = EsjWordConverter.toEntityList(tableDataList);
      return Result.success(entities);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語リストの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<List<EspJpnWord>>> getQuizWordsByWordByPage(
      String word, int size, int currentPage) async {
    try {
      final tableDataList = await _wordDataSource.getQuizWordsByWordByPage(word, size, currentPage);
      final entities = EsjWordConverter.toEntityList(tableDataList);
      return Result.success(entities);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'クイズ用単語リストの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  // @override
  // Future<Result<WordStatus>> getStatusById(int wordId) async {
  //   try {
  //     final tableData = await _wordStatusDataSource.getWordStatusById(wordId);
  //     final entity = WordStatusConverter.toEntity(tableData, wordId);
  //     return Result.success(entity);
  //   } catch (e, s) {
  //     return Result.failure(DatabaseError(
  //       message: '単語ステータスの取得に失敗しました',
  //       originalError: e,
  //       stackTrace: s,
  //     ));
  //   }
  // }
}
