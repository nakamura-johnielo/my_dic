import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_dictionaries.dart';

@DataClassName('JpnEspExampleTableData')
class JpnEspExamples extends Table {
  IntColumn get exampleId => integer().named('jpn_esp_example_id')();
  //IntColumn get dictionaryId => integer().named('jpn_esp_dictionary_id')();
      IntColumn get dictionaryId => integer()
    .named('jpn_esp_dictionary_id')
    .references(JpnEspDictionaries, #dictionaryId, onDelete: KeyAction.cascade)();
  IntColumn get exampleNo => integer().named('example_no')();
  TextColumn get japaneseText => text().named('japanese_text')();
  TextColumn get espanolHtml => text().named('espanol_html')();
  TextColumn get espanolText => text().named('espanol_txt')();

  @override
  Set<Column> get primaryKey => {exampleId};

}
