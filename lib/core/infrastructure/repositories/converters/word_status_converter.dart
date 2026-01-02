import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/shared/consts/dates.dart';

/// Converter class for transforming word status TableData to domain entities
class WordStatusConverter {
  /// Convert EspJpnWordStatusTableData to WordStatus entity
  static WordStatus toEntity(EspJpnWordStatusTableData? data, int wordId) {
    if (data == null) {
      return WordStatus(
        wordId: wordId,
        isLearned: false,
        isBookmarked: false,
        hasNote: false,
        editAt: MyDateTime.sentinel,
      );
    }
    
    return WordStatus(
      wordId: data.wordId,
      isLearned: data.isLearned == 1,
      isBookmarked: data.isBookmarked == 1,
      hasNote: data.hasNote == 1,
      editAt: DateTime.parse(data.editAt).toUtc(),
    );
  }

  /// Convert list of TableData to list of entities
  static List<WordStatus> toEntityList(List<EspJpnWordStatusTableData> dataList) {
    return dataList.map((data) => toEntity(data, data.wordId)).toList();
  }

  /// Convert WordStatus entity to TableData
  static EspJpnWordStatusTableData toTableData(WordStatus entity) {
    return EspJpnWordStatusTableData(
      wordId: entity.wordId,
      isLearned: entity.isLearned ? 1 : 0,
      isBookmarked: entity.isBookmarked ? 1 : 0,
      hasNote: entity.hasNote ? 1 : 0,
      editAt: entity.editAt.toIso8601String(),
    );
  }
}
