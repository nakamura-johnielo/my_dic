import 'package:my_dic/core/infrastructure/datasource/esj/esj_dictionary_dataset.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/entity/dictionary/sub/example/impl/esp_jpn_example.dart';
import 'package:my_dic/core/domain/entity/dictionary/sub/idiom/impl/idiom.dart';
import 'package:my_dic/core/domain/entity/dictionary/sub/supplement.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

/// Converter class for transforming ESP-JPN dictionary TableData to domain entities
class EsjDictionaryConverter {
  /// Convert EsjDictionaryDataSet to EspJpnDictionary entity
  static EspJpnDictionary toEntity(EsjDictionaryDataSet dataSet) {
    return EspJpnDictionary(
      dictionaryId: dataSet.dictionary.dictionaryId,
      word: dataSet.dictionary.word,
      headword: dataSet.dictionary.headword,
      content: dataSet.dictionary.htmlRaw,
      origin: dataSet.dictionary.origin,
      examples: dataSet.examples.isNotEmpty ? _convertExamples(dataSet.examples) : null,
      idioms: dataSet.idioms.isNotEmpty ? _convertIdioms(dataSet.idioms) : null,
      supplements: dataSet.supplements.isNotEmpty ? _convertSupplements(dataSet.supplements) : null,
    );
  }

  /// Convert list of DataSets to list of entities
  static List<EspJpnDictionary> toEntityList(List<EsjDictionaryDataSet> dataSets) {
    return dataSets.map((dataSet) => toEntity(dataSet)).toList();
  }

  /// Convert example TableData list to entity list
  static List<EspJpnExample> _convertExamples(List<EspJpnExampleTableData> exampleList) {
    return exampleList.map((e) => EspJpnExample(
      exampleId: e.exampleId,
      japanese: e.japaneseText,
      espanol: e.espanolText,
    )).toList();
  }

  /// Convert supplement TableData list to entity list
  static List<Supplement> _convertSupplements(List<EspJpnSupplementTableData> supplementList) {
    return supplementList.map((s) => Supplement(
      supplementId: s.supplementId,
      supplement: s.content,
    )).toList();
  }

  /// Convert idiom TableData list to entity list
  static List<Idiom> _convertIdioms(List<EspJpnIdiomTableData> idiomList) {
    return idiomList.map((i) => Idiom(
      idiomId: i.idiomId,
      idiom: i.idiom,
      description: i.description,
    )).toList();
  }
}
