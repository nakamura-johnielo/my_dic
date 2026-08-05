enum SyncFailureKind { retry, pause, deadLetter }

class SyncErrorClassification {
  const SyncErrorClassification(this.kind, this.code);
  final SyncFailureKind kind;
  final String code;
  bool get retryable => kind == SyncFailureKind.retry;
}

/// Feature adapters should expose one of these stable error codes instead of
/// leaking Firebase/HTTP implementation errors into the queue state machine.
class SyncErrorClassifier {
  const SyncErrorClassifier();

  SyncErrorClassification classify(Object error) {
    final value = error.toString().toLowerCase();
    if (value.contains('unauthenticated') ||
        value.contains('permission-denied')) {
      return const SyncErrorClassification(
          SyncFailureKind.pause, 'auth_required');
    }
    if (value.contains('invalid-argument') ||
        value.contains('schema') ||
        value.contains('validation')) {
      return const SyncErrorClassification(
          SyncFailureKind.deadLetter, 'invalid_payload');
    }
    return const SyncErrorClassification(
        SyncFailureKind.retry, 'transient_remote_failure');
  }
}
