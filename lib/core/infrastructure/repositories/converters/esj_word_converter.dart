import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';

/// Converter class for transforming ESP-JPN word TableData to domain entities
class EsjWordConverter {
  /// Convert EspJpnWordTableData to EspJpnWord entity
  static EspJpnWord toEntity(EspJpnWordTableData data) {
    return EspJpnWord(
      wordId: data.wordId,
      word: data.word,
      partOfSpeech: _convertPartOfSpeech(data.partOfSpeech),
    );
  }

  /// Convert list of TableData to list of entities
  static List<EspJpnWord> toEntityList(List<EspJpnWordTableData> dataList) {
    return dataList.map((data) => toEntity(data)).toList();
  }

  /// Convert part of speech string to enum list
  static List<PartOfSpeech> _convertPartOfSpeech(String? data) {
    if (data != null && data.isNotEmpty) {
      return data.split(',').map((str) => _fromString(str)).toList();
    }
    return [PartOfSpeech.none];
  }

  /// Convert string to PartOfSpeech enum
  static PartOfSpeech _fromString(String value) {
    return PartOfSpeech.values.firstWhere(
      (e) => e.display == value,
      orElse: () => PartOfSpeech.none,
    );
  }
}
