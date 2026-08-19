import 'package:my_dic/features/word_status/port/word_status.dart';

/// WordStatus 変更に 1 つのタイムスタンプを割り当てる時計です。
abstract interface class WordStatusClock {
  DateTime now();
}

/// アプリケーションワークフローが使用する完全な WordStatus 機能です。
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
