import 'package:drift/drift.dart';

@DataClassName('EspJpnWordTableData')
class EspJpnWords extends Table {
  @override
  String get tableName => 'words';
  IntColumn get wordId => integer().named('word_id')();
  TextColumn get word => text().named('word')();
  TextColumn get partOfSpeech => text().named('part_of_speech').nullable()();
  TextColumn get partOfSpeechMark =>
      text().named('part_of_speech_mark').nullable()();

  @override
  Set<Column> get primaryKey => {wordId};
}
