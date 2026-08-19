import 'command.dart';
import 'guest_migration.dart';
import 'query.dart';

/// アプリケーションワークフローで使用する MyWord 機能一式。
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
