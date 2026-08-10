/// Stable reason codes carried by sync contexts, cancellations, and reports.
///
/// Application workflows may select these protocol values without importing
/// sync engine internals.
abstract final class SyncReasonCodes {
  static const syncAlreadyRunning = 'sync_already_running';
  static const dependencyFailed = 'dependency_failed';
  static const handlerUnavailable = 'handler_unavailable';
  static const sessionChanged = 'session_changed';
  static const callerCancelled = 'caller_cancelled';
  static const offline = 'offline';
  static const authRequired = 'auth_required';
  static const invalidPayload = 'invalid_payload';
  static const transientRemoteFailure = 'transient_remote_failure';
  static const handlerException = 'handler_exception';
  static const sessionReady = 'session_ready';
  static const appResumed = 'app_resumed';
  static const postGuestMigration = 'post_guest_migration';
  static const manual = 'manual';
  static const retryDue = 'retry_due';
}
