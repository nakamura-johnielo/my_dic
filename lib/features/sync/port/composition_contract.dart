import 'outbox_writer.dart';
import 'sync_checkpoint_store.dart';
import 'sync_handler_runtime.dart';
import 'sync_queue.dart';

/// 1 つのアプリケーションスコープ用の完成済み Sync インフラストラクチャです。
///
/// アプリ構成がこのバンドルのライフタイムを所有します。データセットレジストリは完成済みの
/// ハンドラーのみを使用し、これらの機能を自ら構築しません。
final class SyncComposition {
  const SyncComposition({
    required this.queue,
    required this.checkpointStore,
    required this.outboxWriter,
    required this.handlerRuntime,
  });

  final SyncQueue queue;
  final SyncCheckpointStore checkpointStore;
  final OutboxWriter outboxWriter;
  final SyncHandlerRuntime handlerRuntime;
}
