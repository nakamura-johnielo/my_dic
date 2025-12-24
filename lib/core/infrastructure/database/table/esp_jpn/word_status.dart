import 'package:drift/drift.dart';

@DataClassName('EspJpnWordStatusTableData')
class EspJpnWordStatus extends Table {
  @override
  String get tableName => 'word_status';
  IntColumn get wordId => integer().named('word_id')();
  IntColumn get isLearned => integer().named('is_learned').nullable()();
  IntColumn get isBookmarked => integer().named('is_bookmarked').nullable()();
  IntColumn get hasNote => integer().named('has_note').nullable()();
  TextColumn get editAt => text().named('edit_at')();

  @override
  Set<Column> get primaryKey => {wordId};

  @override
  List<String> get customConstraints =>
      ['FOREIGN KEY(word_id) REFERENCES words(word_id)'];
}
