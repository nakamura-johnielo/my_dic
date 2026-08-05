import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart';

/// Converter class for transforming jpn_esp word status TableData to domain entities
class JpnEspWordStatusConverter {
  /// Convert JpnEspWordStatusTableData to JpnEspWordStatus entity
  static JpnEspWordStatus toEntity(JpnEspWordStatusTableData data) {
    return JpnEspWordStatus(
      wordId: data.wordId,
      isLearned: data.isLearned == 1,
      isBookmarked: data.isBookmarked == 1,
      hasNote: data.hasNote == 1,
      editAt: DateTime.parse(data.editAt).toUtc(),
    );
  }

  /// Convert list of TableData to list of entities
  static List<JpnEspWordStatus> toEntityList(
      List<JpnEspWordStatusTableData> dataList) {
    return dataList.map((data) => toEntity(data)).toList();
  }

  /// Convert JpnEspWordStatus entity to TableData
  static JpnEspWordStatusTableData toTableData(JpnEspWordStatus entity) {
    return JpnEspWordStatusTableData(
      wordId: entity.wordId,
      isLearned: entity.isLearned ? 1 : 0,
      isBookmarked: entity.isBookmarked ? 1 : 0,
      hasNote: entity.hasNote ? 1 : 0,
      editAt: entity.editAt.toIso8601String(),
      accountId: 'legacy_unowned',
      localRevision: 0,
    );
  }
}
