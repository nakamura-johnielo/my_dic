import 'package:my_dic/features/word_status/port/word_status.dart';

/// Clock used to assign one timestamp to a WordStatus mutation.
abstract interface class WordStatusClock {
  DateTime now();
}

/// The complete WordStatus capabilities consumed by application workflows.
final class WordStatusPorts {
  const WordStatusPorts({
    required this.reader,
    required this.watcher,
    required this.batchReader,
    required this.commands,
    required this.guestMigration,
  });

  final WordStatusReaderPort reader;
  final WordStatusWatchPort watcher;
  final WordStatusBatchReaderPort batchReader;
  final WordStatusCommandPort commands;
  final WordStatusGuestMigrationPort guestMigration;
}
