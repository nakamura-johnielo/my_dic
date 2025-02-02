import 'package:drift/drift.dart';

class MyWords extends Table {
  IntColumn get myWordId => integer().named('my_word_id')();
  TextColumn get word => text().named('word')();
  TextColumn get contents => text().named('contents').nullable()();
  /* TextColumn get partOfSpeech => text().named('part_of_speech').nullable()();
  TextColumn get partOfSpeechMark =>
      text().named('part_of_speech_mark').nullable()(); */

  @override
  Set<Column> get primaryKey => {myWordId};
}
