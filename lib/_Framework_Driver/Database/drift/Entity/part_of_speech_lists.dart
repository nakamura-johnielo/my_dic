import 'package:drift/drift.dart';

class PartOfSpeechLists extends Table {
  IntColumn get partOfSpeechId => integer().named('part_of_speech_id')();
  IntColumn get wordId => integer().named('word_id')();
  TextColumn get partOfSpeech => text().named('part_of_speech')();

  @override
  Set<Column> get primaryKey => {partOfSpeechId};

  @override
  List<String> get customConstraints =>
      ['FOREIGN KEY(word_id) REFERENCES words(word_id)'];
}
