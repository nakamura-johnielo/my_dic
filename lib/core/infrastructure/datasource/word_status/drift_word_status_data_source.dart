import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/consts/dates.dart';

import 'i_local_word_status_data_source.dart';

class DriftWordStatusDataSource implements ILocalWordStatusDataSource {
  final EspJpnWordStatusDao _dao;
  DriftWordStatusDataSource(this._dao);

  @override
  Future<WordStatus> getWordStatusById(int id) async {
    final data = await _dao.getStatusById(id);
    if (data == null) {
      return WordStatus(
        wordId: id,
        isLearned: false,
        isBookmarked: false,
        hasNote: false,
        editAt: MyDateTime.sentinel,
      );
    }
   return _toEntity(data);
  }

  @override
  Future<List<WordStatus>> getWordStatusAfter(DateTime datetime) async {
    final list = await _dao.getWordStatusAfter(datetime);
    return list
        .map((data) => _toEntity(data)).toList();
  }

  @override
  Future<void> updateWordStatus(WordStatus wordStatus) async {
     final data = _toTableData(wordStatus);
    
    if (await _dao.exist(wordStatus.wordId)) {
      await _dao.updateStatus(data);
    } else {
      await _dao.insertStatus(data);
    }
  }

  @override
  Stream<WordStatus> watchWordStatusById(int id) {
    return _dao.watchWordStatus(id).map((d) {
      if (d == null) {
        return WordStatus(
          wordId: id,
          isLearned: false,
          isBookmarked: false,
          hasNote: false,
          editAt: MyDateTime.sentinel,
        );
      }
      return WordStatus(
        wordId: d.wordId,
        isLearned: d.isLearned == 1,
        isBookmarked: d.isBookmarked == 1,
        hasNote: d.hasNote == 1,
        editAt: DateTime.parse(d.editAt).toUtc(),
      );
    });
  }

  @override
  Stream<List<int>> watchChangedIds(DateTime datetime) {
    return _dao.watchChangedWordIdsWithFilter(datetime);
  }

  
  // Entity <-> TableData 変換
  WordStatus _toEntity(EspJpnWordStatusTableData data) {
    return WordStatus(
      wordId: data.wordId,
      isLearned: data.isLearned == 1,
      isBookmarked: data.isBookmarked == 1,
      hasNote: data.hasNote == 1,
      editAt: DateTime.parse(data.editAt).toUtc(),
    );
  }

  EspJpnWordStatusTableData _toTableData(WordStatus entity) {
    return EspJpnWordStatusTableData(
      wordId: entity.wordId,
      isLearned: entity.isLearned ? 1 : 0,
      isBookmarked: entity.isBookmarked ? 1 : 0,
      hasNote: entity.hasNote ? 1 : 0,
      editAt: entity.editAt.toIso8601String(), //TODO millis epoch intに変換
    );
  }
}
