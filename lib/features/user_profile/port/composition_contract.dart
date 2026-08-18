import 'command.dart';
import 'guest_migration.dart';
import 'query.dart';

/// Clock used to assign the existing client timestamp to profile mutations.
abstract interface class UserProfileClock {
  DateTime now();
}

/// Completed UserProfile capabilities for one application scope.
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
