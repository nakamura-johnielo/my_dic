import 'package:drift/drift.dart';

/// ローカルファーストのユーザープロフィール。既存のSharedPreferencesデータは、移行時に
/// 意図的にサインイン済みアカウントへ割り当てません。
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
