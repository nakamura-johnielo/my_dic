import 'package:drift/drift.dart';

class JpnEspExamples extends Table {
  IntColumn get exampleId => integer().named('jpn_esp_example_id')();
  IntColumn get dictionaryId => integer().named('jpn_esp_dictionary_id')();
  IntColumn get exampleNo => integer().named('example_no')();
  TextColumn get japaneseText => text().named('japanese_text')();
  TextColumn get espanolHtml => text().named('espanol_html')();
  TextColumn get espanolText => text().named('espanol_txt')();

  @override
  Set<Column> get primaryKey => {exampleId};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY(jpn_esp_dictionary_id) REFERENCES jpn_esp_dictionaries(jpn_esp_dictionary_id)'
      ];
}
