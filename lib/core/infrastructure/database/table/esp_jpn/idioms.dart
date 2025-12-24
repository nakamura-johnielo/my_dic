import 'package:drift/drift.dart';

@DataClassName('EspJpnIdiomTableData')
class EspJpnIdioms extends Table {
  @override
  String get tableName => 'idioms';
  IntColumn get idiomId => integer().named('idiom_id')();
  IntColumn get dictionaryId => integer().named('dictionary_id')();
  IntColumn get idiomNo => integer().named('idiom_no')();
  TextColumn get idiom => text().named('idiom')();
  TextColumn get description => text().named('description')();

  @override
  Set<Column> get primaryKey => {idiomId};

  @override
  List<String> get customConstraints =>
      ['FOREIGN KEY(dictionary_id) REFERENCES dictionaries(dictionary_id)'];
}
