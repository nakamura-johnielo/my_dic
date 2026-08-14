/// Sole business-facing surface for Sync workflows.
///
/// Dataset implementations use `dataset_contract.dart`; app composition uses
/// `composition.dart`. Neither technical seam is re-exported here.
export 'cancellation_token.dart';
export 'model/sync_context.dart';
export 'model/sync_mutation.dart';
export 'outbox_writer.dart';
export 'session_fence.dart';
export 'sync_reason_codes.dart';
export 'sync_run_outcome.dart';
export 'sync_runner.dart';
