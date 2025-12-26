import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/dictionaries.dart';

@DataClassName('EspJpnIdiomTableData')
class EspJpnIdioms extends Table {
  @override
  String get tableName => 'idioms';
  IntColumn get idiomId => integer().named('idiom_id')();
    IntColumn get dictionaryId => integer()
    .named('dictionary_id')
    .nullable()
    .references(EspJpnDictionaries, #dictionaryId, onDelete: KeyAction.cascade)();

  IntColumn get idiomNo => integer().named('idiom_no')();
  TextColumn get idiom => text().named('idiom')();
  TextColumn get description => text().named('description')();

  @override
  Set<Column> get primaryKey => {idiomId};

}
