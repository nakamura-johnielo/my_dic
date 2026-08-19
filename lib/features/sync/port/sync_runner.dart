import 'model/sync_context.dart';
import 'sync_run_outcome.dart';

/// フォアグラウンド Sync 用の公開ワークフローエントリポイントです。
abstract interface class SyncRunner {
  Future<SyncRunOutcome> foreground(SyncContext context);

  void cancelRetryForAccount(String accountId);

  void dispose();
}
