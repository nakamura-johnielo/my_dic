import 'package:drift/drift.dart';

class SyncOutbox extends Table {
  TextColumn get mutationId => text()();
  TextColumn get accountId => text()();
  TextColumn get dataset => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  TextColumn get fieldMask => text()();
  IntColumn get payloadVersion => integer()();
  IntColumn get localRevision => integer()();
  TextColumn get baseRemoteRevision => text().nullable()();
  TextColumn get state => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime()();
  TextColumn get leaseToken => text().nullable()();
  DateTimeColumn get leaseUntil => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get lastErrorCode => text().nullable()();
  @override
  Set<Column> get primaryKey => {mutationId};
  @override
  List<String> get customConstraints =>
      ["CHECK (account_id <> '')", "CHECK (entity_id <> '')"];
}
