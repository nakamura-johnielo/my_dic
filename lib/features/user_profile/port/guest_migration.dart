import 'package:my_dic/features/sync/port/outbox_writer.dart';

/// UserProfile's contribution to the app-owned, cross-feature guest migration.
abstract interface class UserProfileGuestMigrationPort {
  Future<bool> hasGuestProfile();

  Future<void> migrateGuestProfile({
    required String accountId,
    required String migrationId,
    required IOutboxWriter outboxWriter,
    required DateTime Function() clock,
  });
}
