import 'model/sync_context.dart';
import 'sync_run_outcome.dart';

/// Public workflow entry point for foreground Sync.
abstract interface class ISyncRunner {
  Future<SyncRunOutcome> foreground(SyncContext context);

  void cancelRetryForAccount(String accountId);

  void dispose();
}
