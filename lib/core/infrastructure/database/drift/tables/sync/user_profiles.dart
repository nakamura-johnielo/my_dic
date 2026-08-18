import 'package:drift/drift.dart';

/// Local-first user profile. Existing SharedPreferences data is intentionally
/// not assigned to a signed-in account during migration.
class UserProfiles extends Table {
  TextColumn get accountId => text()();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  IntColumn get localRevision =>
      integer().named('local_revision').withDefault(const Constant(0))();
  TextColumn get remoteRevision => text().named('remote_revision').nullable()();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
  TextColumn get lastMutationId =>
      text().named('last_mutation_id').nullable()();
  @override
  Set<Column> get primaryKey => {accountId};
  @override
  List<String> get customConstraints => ["CHECK (account_id <> '')"];
}
