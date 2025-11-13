import 'package:drift/drift.dart';

class EsEnConjugacions extends Table {
  IntColumn get wordId => integer().named('word_id').autoIncrement()();
  TextColumn get word => text().nullable()();
  TextColumn get english => text().nullable()();
  TextColumn get present3rd => text().named('present_3rd').nullable()();
  TextColumn get presentP => text().named('present_p').nullable()();
  TextColumn get past => text().nullable()();
  TextColumn get pastP => text().named('past_p').nullable()();

  @override
  Set<Column> get primaryKey => {wordId};

  @override
  List<String> get customConstraints =>
      ['FOREIGN KEY(word_id) REFERENCES words(word_id)'];
}
