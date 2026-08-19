import 'command.dart';
import 'guest_migration.dart';
import 'query.dart';

/// プロフィール変更に既存のクライアント時刻を割り当てるための時計です。
abstract interface class UserProfileClock {
  DateTime now();
}

/// 1 つのアプリケーションスコープに対する完成済みの UserProfile 機能です。
final class UserProfilePorts {
  const UserProfilePorts({
    required this.query,
    required this.commands,
    required this.guestMigration,
  });

  final UserProfileQueryPort query;
  final UserProfileCommandPort commands;
  final UserProfileGuestMigrationPort guestMigration;
}
