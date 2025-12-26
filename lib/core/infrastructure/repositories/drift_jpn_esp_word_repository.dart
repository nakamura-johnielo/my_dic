import 'dart:developer';

import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_word_repository.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_dictionary_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
;
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';

class DriftJpnEspWordRepository implements IJpnEspWordRepository {
  final JpnEspWordDao _jpnEspWordDao;
  final JpnEspDictionaryDao _jpnEspDictionaryDao;
  //final JpnEspWordDao _jpnEspWordDao;
  //final JpnEspDictionaryDao _jpnEspDictionaryDao;
  //final PartOfSpeechListDao _pslDao;
  DriftJpnEspWordRepository(this._jpnEspWordDao, this._jpnEspDictionaryDao);

  @override
  Future<Result<List<JpnEspWord>>> getWordsByWord(
      String word, int size, int currentPage) async {
    try {
      final words = await _jpnEspWordDao.getWordsByWord(word, size, currentPage);

      if (words == null) return Result.success([]);
      //final partOfSpeech=await _pslDao.getPartOfSpeechListByWordId(word)
      final result = words.map((word) {
        return JpnEspWord(
          id: word.wordId,
          word: word.word,
        );
      }).toList();
      return Result.success(result);
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
      EspJpnWordStatusTableData data = EspJpnWordStatusTableData(
        wordId: input.wordId,
        isLearned: input.status.contains(FeatureTag.isLearned) ? 1 : 0,
        isBookmarked: input.status.contains(FeatureTag.isBookmarked) ? 1 : 0,
        hasNote: input.status.contains(FeatureTag.hasNote) ? 1 : 0,
        editAt: input.editAt,
      );

      /* if (await _jpnEspDictionaryDao.exist(input.wordId)) {
        _jpnEspDictionaryDao.updateStatus(data);
        return;
      }
      _jpnEspDictionaryDao.insertStatus(data); */
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
