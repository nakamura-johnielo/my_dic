import 'dart:developer';

import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_word_repository.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp/i_jpn_esp_word_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp/i_jpn_esp_dictionary_data_source.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/infrastructure/repositories/converters/jpn_esp_word_converter.dart';

class JpnEspWordRepository implements IJpnEspWordRepository {
  final IJpnEspWordLocalDataSource _wordDataSource;
  final IJpnEspDictionaryLocalDataSource _dictionaryDataSource;
  JpnEspWordRepository(this._wordDataSource, this._dictionaryDataSource);

  @override
  Future<Result<List<JpnEspWord>>> getWordsByWord(
      String word, int size, int currentPage) async {
    try {
      final tableDataList = await _wordDataSource.getWordsByWord(word, size, currentPage);
      final entities = JpnEspWordConverter.toEntityList(tableDataList);
      return Result.success(entities);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: '和西単語の検索に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<void>> updateStatus(UpdateStatusRepositoryInputData input) async {
    try {//TODO remove ここでは使わない
      log("updatestatusrepo");
      await _wordDataSource.updateStatus(input);
      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: '和西単語ステータスの更新に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
