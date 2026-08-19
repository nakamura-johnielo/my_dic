/// アプリ所有の機能横断ゲスト移行に対する UserProfile の担当部分です。
abstract interface class UserProfileGuestMigrationPort {
  Future<bool> hasGuestProfile();

  Future<void> migrateGuestProfile({
    required String accountId,
    required String migrationId,
  });
}
