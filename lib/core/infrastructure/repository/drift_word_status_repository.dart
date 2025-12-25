import 'package:my_dic/core/common/consts/dates.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/esp_jpn/esp_jpn_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/database_provider.dart';

class DriftWordStatusRepository implements ILocalWordStatusRepository {
  final EspJpnWordStatusDao _dao;

  DriftWordStatusRepository(this._dao);

  @override
  Future<WordStatus> getWordStatusById(int id) async {
    final data = await _dao.getStatusById(id);
    if (data == null) {
      // デフォルト値を返す
      return WordStatus(
        wordId: id,
        isLearned: false,
        isBookmarked: false,
        hasNote: false,
        editAt: data?.editAt != null
            ? DateTime.parse(data!.editAt).toUtc()
            : MyDateTime.sentinel,
      );
    }
    return _toEntity(data);
  }

  @override
  Future<List<WordStatus>> getWordStatusAfter(DateTime datetime) async {
    final dataList = await _dao.getWordStatusAfter(datetime);
    if (dataList.isEmpty) {
      return [];
    }
    return dataList.map((data) => _toEntity(data)).toList();
  }

  @override
  Future<void> updateWordStatus(WordStatus wordStatus) async {
    final data = _toTableData(wordStatus);
    final exists = await _dao.exist(wordStatus.wordId);

    if (exists) {
      await _dao.updateStatus(data);
    } else {
      await _dao.insertStatus(data);
    }
  }

  @override
  Stream<WordStatus> watchWordStatusById(int id) async* {
    // DriftのwatchをStreamに変換
    // ※ DAOに watch メソッドがない場合は追加が必要
    // 暫定で polling 実装
    while (true) {
      //yield await getWordStatusById(id);
      await Future.delayed(Duration(seconds: 1));
    }
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

  @override
  Stream<List<int>> watchChangedIds(DateTime datetime) {
    //return _dao.watchChangedWordIds();//TODO datetimeでフィルタで効率化
    return _dao.watchChangedWordIdsWithFilter(datetime);
  }
}
