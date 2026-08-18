import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/words.dart';

@DataClassName('EspJpnWordStatusTableData')
class EspJpnWordStatus extends Table {
  @override
  String get tableName => 'word_status';

  IntColumn get wordId => integer()
      .named('word_id')
      .references(EspJpnWords, #wordId, onDelete: KeyAction.cascade)();
  IntColumn get isLearned => integer().named('is_learned').nullable()();
  IntColumn get isBookmarked => integer().named('is_bookmarked').nullable()();
  IntColumn get hasNote => integer().named('has_note').nullable()();
  TextColumn get editAt => text().named('edit_at')();
  TextColumn get accountId => text()
      .named('account_id')
      .withDefault(const Constant('legacy_unowned'))();
  IntColumn get localRevision =>
      integer().named('local_revision').withDefault(const Constant(0))();
  TextColumn get remoteRevision => text().named('remote_revision').nullable()();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
  TextColumn get lastMutationId =>
      text().named('last_mutation_id').nullable()();

  @override
  Set<Column> get primaryKey => {accountId, wordId};
  @override
  List<String> get customConstraints => ["CHECK (account_id <> '')"];
  //TODO TextColumn get accountId => text().check(accountId.isNotValue(''))();
}
