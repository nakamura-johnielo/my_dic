import 'package:drift/drift.dart';

@DataClassName('JpnEspWordStatusTableData')
class JpnEspWordStatus extends Table {
  IntColumn get wordId => integer().named('jpn_esp_word_id')();
  IntColumn get isLearned => integer().named('is_learned').nullable()();
  IntColumn get isBookmarked => integer().named('is_bookmarked').nullable()();
  IntColumn get hasNote => integer().named('has_note').nullable()();
  TextColumn get editAt => text().named('edit_at')();

  @override
  Set<Column> get primaryKey => {wordId};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY(jpn_esp_word_id) REFERENCES jpn_esp_words(jpn_esp_word_id)'
      ];
}
