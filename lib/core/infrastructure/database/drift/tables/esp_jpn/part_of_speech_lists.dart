import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/words.dart';

class PartOfSpeechLists extends Table {
  IntColumn get partOfSpeechId => integer().named('part_of_speech_id')();
  
  IntColumn get wordId => integer()
    .named('word_id')
    .references(EspJpnWords, #wordId, onDelete: KeyAction.cascade)();
  TextColumn get partOfSpeech => text().named('part_of_speech')();

  @override
  Set<Column> get primaryKey => {partOfSpeechId};

}
