import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_word.dart';

@DataClassName('JpnEspDictionaryTableData')
class JpnEspDictionaries extends Table {
  IntColumn get dictionaryId => integer().named('jpn_esp_dictionary_id')();
      IntColumn get wordId => integer()
    .named('jpn_esp_word_id')
    .references(JpnEspWords, #wordId, onDelete: KeyAction.cascade)();

  // IntColumn get wordId => integer().named('jpn_esp_word_id')();
  TextColumn get word => text().named('word')();
  IntColumn get excf => integer().named('excf')();
  TextColumn get headword => text().named('headword')();
  TextColumn get content => text().named('content')();
  TextColumn get htmlRaw => text().named('html_raw')();

  @override
  Set<Column> get primaryKey => {dictionaryId};

  
}
