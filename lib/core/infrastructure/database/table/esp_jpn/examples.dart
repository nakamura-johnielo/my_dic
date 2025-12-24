import 'package:drift/drift.dart';

@DataClassName('EspJpnExampleTableData')
class EspJpnExamples extends Table {
  @override
  String get tableName => 'examples';
  IntColumn get exampleId => integer().named('example_id')();
  IntColumn get dictionaryId => integer().named('dictionary_id')();
  IntColumn get exampleNo => integer().named('example_no')();
  TextColumn get espanolHtml => text().named('espanol_html')();
  TextColumn get japaneseText => text().named('japanese_text')();
  TextColumn get espanolText => text().named('espanol_text')();

  @override
  Set<Column> get primaryKey => {exampleId};

  @override
  List<String> get customConstraints =>
      ['FOREIGN KEY(dictionary_id) REFERENCES dictionaries(dictionary_id)'];
}
