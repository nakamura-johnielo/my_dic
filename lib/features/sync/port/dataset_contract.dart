/// Technical SPI implemented by dataset owners and consumed by their
/// composition/infrastructure code.
///
/// This is intentionally separate from the workflow-facing `sync.dart`.
export 'cancellation_token.dart';
export 'dataset_sync_gateway.dart';
export 'dataset_sync_handler.dart';
export 'model/dataset_sync_result.dart';
export 'model/mutation_lease.dart';
export 'model/remote_mutation.dart';
export 'model/sync_context.dart';
export 'model/sync_cursor.dart';
export 'model/sync_mutation.dart';
export 'model/sync_report.dart';
export 'outbox_writer.dart';
export 'remote_mutation_executor.dart';
export 'session_fence.dart';
export 'sync_checkpoint_store.dart';
export 'sync_dataset.dart';
export 'sync_handler_runtime.dart';
export 'sync_queue.dart';
export 'sync_reason_codes.dart';
export 'sync_retry_wakeup.dart';
export 'sync_run_outcome.dart';
export 'sync_runner.dart';
export 'sync_telemetry.dart';
