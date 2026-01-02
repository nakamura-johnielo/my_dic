import 'package:my_dic/core/infrastructure/datasource/jpn_esp/jpn_esp_dictionary_dataset.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/example/jpn_esp_example.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

/// Converter class for transforming JPN-ESP dictionary TableData to domain entities
class JpnEspDictionaryConverter {
  /// Convert JpnEspDictionaryDataSet to JpnEspDictionary entity
  static JpnEspDictionary toEntity(JpnEspDictionaryDataSet dataSet) {
    return JpnEspDictionary(
      id: dataSet.dictionary.dictionaryId,
      wordId: dataSet.dictionary.wordId,
      word: dataSet.dictionary.word,
      headword: dataSet.dictionary.headword,
      content: dataSet.dictionary.htmlRaw,
      examples: dataSet.examples.isNotEmpty ? _convertExamples(dataSet.examples) : null,
    );
  }

  /// Convert list of DataSets to list of entities
  static List<JpnEspDictionary> toEntityList(List<JpnEspDictionaryDataSet> dataSets) {
    return dataSets.map((dataSet) => toEntity(dataSet)).toList();
  }

  /// Convert example TableData list to entity list
  static List<JpnEspExampleWith> _convertExamples(List<JpnEspExampleTableData> exampleList) {
    return exampleList.map((e) => JpnEspExampleWith(
      exampleId: e.exampleId,
      japanese: e.japaneseText,
      espanol: e.espanolText,
      espanolHtml: e.espanolHtml,
    )).toList();
  }
}
