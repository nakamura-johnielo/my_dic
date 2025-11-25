import 'package:drift/drift.dart';

class Rankings extends Table {
  IntColumn get rankingId => integer().named('ranking_id')();
  IntColumn get rankingNo => integer().named('ranking_no')();
  TextColumn get word => text().nullable()();
  TextColumn get wordOrigin => text().named('word_origin').nullable()();
  IntColumn get wordId => integer().named('word_id').nullable()();
  //conjuがあるかSQLで確認する。０，１
  IntColumn get hasConj => integer().named('has_conj').nullable()();

  @override
  Set<Column> get primaryKey => {rankingId};

  @override
  List<String> get customConstraints =>
      ['FOREIGN KEY(word_id) REFERENCES words(word_id)'];
}
