import 'package:drift/drift.dart';

@DataClassName('SupplementTableData')
class Supplements extends Table {
  IntColumn get supplementId => integer().named('supplement_id')();
  IntColumn get dictionaryId => integer().named('dictionary_id')();
  IntColumn get supplementNo => integer().named('supplement_no')();
  TextColumn get content => text().named('content')();
  TextColumn get exampleId => text().named('example_id').nullable()();

  @override
  Set<Column> get primaryKey => {supplementId};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY(dictionary_id) REFERENCES dictionaries(dictionary_id)',
        'FOREIGN KEY(example_id) REFERENCES examples(example_id)'
      ];
}
