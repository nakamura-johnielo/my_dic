import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/words.dart';

@DataClassName('EspJpnDictionaryTableData')
class EspJpnDictionaries extends Table {
  @override
  String get tableName => 'dictionaries';

  IntColumn get dictionaryId => integer().named('dictionary_id')();
  
  IntColumn get wordId => integer()
    .named('word_id')
    .references(EspJpnWords, #wordId, onDelete: KeyAction.cascade)();
  TextColumn get word => text()();
  IntColumn get excf => integer().nullable()();
  TextColumn get headword => text().nullable()();
  TextColumn get partOfSpeech => text().named('part_of_speech').nullable()();
  TextColumn get partOfSpeechMark =>
      text().named('part_of_speech_mark').nullable()();
  TextColumn get content => text().nullable()();
  TextColumn get origin => text().nullable()();
  TextColumn get htmlRaw => text().named('html_raw').nullable()();

  @override
  Set<Column> get primaryKey => {dictionaryId};

}
