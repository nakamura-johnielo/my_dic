/// UI/workflow-safe result of a requested Sync run.
///
/// A durable retry has already been persisted before [retryScheduled] is
/// returned. It is therefore distinct from a [nonRetryableFailure].
enum SyncRunOutcome {
  success,
  retryScheduled,
  nonRetryableFailure,
  cancelled,
}
