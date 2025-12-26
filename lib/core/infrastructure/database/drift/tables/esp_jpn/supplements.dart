import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/dictionaries.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/examples.dart';

@DataClassName('EspJpnSupplementTableData')
class EspJpnSupplements extends Table {
  @override
  String get tableName => 'supplements';
  IntColumn get supplementId => integer().named('supplement_id')();
  IntColumn get dictionaryId => integer()
      .named('dictionary_id')
      .nullable()
      .references(EspJpnDictionaries, #dictionaryId,
          onDelete: KeyAction.cascade)();

  IntColumn get supplementNo => integer().named('supplement_no')();
  TextColumn get content => text().named('content')();
  IntColumn get exampleId => integer()
      .named('example_id')
      .nullable()
      .references(EspJpnExamples, #exampleId, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {supplementId};
}
