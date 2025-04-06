import 'package:drift/drift.dart';

class MyWordStatus extends Table {
  IntColumn get myWordId => integer().named('my_word_id')();
  IntColumn get isLearned => integer().named('is_learned').nullable()();
  IntColumn get isBookmarked => integer().named('is_bookmarked').nullable()();
  IntColumn get hasNote => integer().named('has_note').nullable()();
  TextColumn get editAt => text().named('edit_at')();

  @override
  Set<Column> get primaryKey => {myWordId};

/*   @override
  List<String> get customConstraints =>
      ['FOREIGN KEY(word_id) REFERENCES words(word_id)']; */
}
