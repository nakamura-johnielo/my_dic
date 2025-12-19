import 'package:drift/drift.dart';

@DataClassName('JpnEspDictionaryTableData')
class JpnEspDictionaries extends Table {
  IntColumn get dictionaryId => integer().named('jpn_esp_dictionary_id')();
  IntColumn get wordId => integer().named('jpn_esp_word_id')();
  TextColumn get word => text()();
  IntColumn get excf => integer()();
  TextColumn get headword => text()();
  TextColumn get content => text()();
  TextColumn get htmlRaw => text().named('html_raw')();

  @override
  Set<Column> get primaryKey => {dictionaryId};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY(jpn_esp_word_id) REFERENCES jpn_esp_words(jpn_esp_word_id)'
      ];
}
