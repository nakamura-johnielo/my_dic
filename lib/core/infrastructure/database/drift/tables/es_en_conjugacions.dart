import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/words.dart';

@DataClassName('EsEnConjugacionTableData')
class EsEnConjugacions extends Table {
  // IntColumn get wordId => integer().named('word_id').autoIncrement()();
  TextColumn get word => text().nullable()();
  TextColumn get english => text().nullable()();
  TextColumn get present3rd => text().named('present_3rd').nullable()();
  TextColumn get presentP => text().named('present_p').nullable()();
  TextColumn get past => text().nullable()();
  TextColumn get pastP => text().named('past_p').nullable()();

  IntColumn get wordId => integer()
    .named('word_id')
    .references(EspJpnWords, #wordId, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {wordId};

}
