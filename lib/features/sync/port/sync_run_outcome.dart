/// UI/workflow-safe result of a requested Sync run.
///
/// A durable retry has already been persisted before [retryScheduled] is
/// returned. It is therefore distinct from a non-retryable [failure].
enum SyncRunOutcome { success, retryScheduled, failure, cancelled }
