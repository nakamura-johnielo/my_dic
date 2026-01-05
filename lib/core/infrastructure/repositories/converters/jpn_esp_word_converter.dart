import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';

/// Converter class for transforming JPN-ESP word TableData to domain entities
class JpnEspWordConverter {
  /// Convert JpnEspWordTableData to JpnEspWord entity
  static JpnEspWord toEntity(JpnEspWordTableData data) {
    return JpnEspWord(
      id: data.wordId,
      word: data.word,
    );
  }

  /// Convert list of TableData to list of entities
  static List<JpnEspWord> toEntityList(List<JpnEspWordTableData> dataList) {
    return dataList.map((data) => toEntity(data)).toList();
  }
}
