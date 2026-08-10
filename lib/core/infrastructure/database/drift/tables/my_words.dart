import 'package:drift/drift.dart';

@DataClassName('MyWordTableData')
class MyWords extends Table {
  TextColumn get myWordId => text().named('my_word_id')();
  TextColumn get word => text().named('word')();
  TextColumn get contents => text().named('contents').nullable()();
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
  Set<Column> get primaryKey => {accountId, myWordId};
  @override
  List<String> get customConstraints => ["CHECK (account_id <> '')"];
}
