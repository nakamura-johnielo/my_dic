/// Schedules the next persisted outbox retry for an account.
///
/// The queue remains the source of truth for retry times. Implementations keep
/// at most one wake-up per account and never persist scheduling state.
abstract interface class SyncRetryWakeup {
  void arm({
    required String accountId,
    required DateTime dueAt,
    required void Function() onDue,
  });

  void cancel(String accountId);
  void dispose();
}
