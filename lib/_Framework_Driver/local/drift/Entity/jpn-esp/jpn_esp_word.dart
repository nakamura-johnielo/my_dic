import 'package:drift/drift.dart';

class JpnEspWords extends Table {
  IntColumn get wordId => integer().named('jpn_esp_word_id')();
  TextColumn get word => text().named('word')();

  @override
  Set<Column> get primaryKey => {wordId};
}
