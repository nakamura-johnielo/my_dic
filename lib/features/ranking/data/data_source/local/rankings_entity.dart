import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/words.dart';


@DataClassName('RankingTableData')
class Rankings extends Table {
  IntColumn get rankingId => integer().named('ranking_id')();
  IntColumn get rankingNo => integer().named('ranking_no')();
  TextColumn get word => text().nullable()();
  TextColumn get wordOrigin => text().named('word_origin').nullable()();
  //IntColumn get wordId => integer().named('word_id').nullable()();
  //conjuがあるかSQLで確認する。０，１
  IntColumn get hasConj => integer().named('has_conj').nullable()();

  IntColumn get wordId => integer()
    .named('word_id')
    .nullable()
    .references(EspJpnWords, #wordId, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {rankingId};

}
