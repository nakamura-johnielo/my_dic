import 'package:drift/drift.dart';

class SyncCheckpoints extends Table {
  TextColumn get accountId => text()();
  TextColumn get dataset => text()();
  IntColumn get cursorSeconds => integer()();
  IntColumn get cursorNanoseconds => integer()();
  TextColumn get cursorDocumentId => text()();
  DateTimeColumn get lastSuccessfulAt => dateTime()();
  @override
  Set<Column> get primaryKey => {accountId, dataset};
  @override
  List<String> get customConstraints => ["CHECK (account_id <> '')"];
}
