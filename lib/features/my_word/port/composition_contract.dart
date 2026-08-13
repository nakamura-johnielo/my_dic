import 'command.dart';
import 'guest_migration.dart';
import 'query.dart';

/// The complete set of MyWord capabilities used by application workflows.
final class MyWordPorts {
  const MyWordPorts({
    required this.reader,
    required this.commands,
    required this.statusCommands,
    required this.guestMigration,
  });

  final MyWordQueryPort reader;
  final MyWordCommandPort commands;
  final MyWordStatusCommandPort statusCommands;
  final MyWordGuestMigrationPort guestMigration;
}
