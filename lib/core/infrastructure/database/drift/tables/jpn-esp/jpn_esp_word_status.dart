import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_word.dart';

@DataClassName('JpnEspWordStatusTableData')
class JpnEspWordStatus extends Table {
      IntColumn get wordId => integer()
    .named('jpn_esp_word_id')
    .references(JpnEspWords, #wordId, onDelete: KeyAction.cascade)();
  IntColumn get isLearned => integer().named('is_learned').nullable()();
  IntColumn get isBookmarked => integer().named('is_bookmarked').nullable()();
  IntColumn get hasNote => integer().named('has_note').nullable()();
  TextColumn get editAt => text().named('edit_at')();

  @override
  Set<Column> get primaryKey => {wordId};


}
