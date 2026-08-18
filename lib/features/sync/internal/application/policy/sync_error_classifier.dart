import 'package:my_dic/features/sync/port/sync_reason_codes.dart';

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
          SyncFailureKind.pause, SyncReasonCodes.authRequired);
    }
    if (value.contains('invalid-argument') ||
        value.contains('schema') ||
        value.contains('validation')) {
      return const SyncErrorClassification(
          SyncFailureKind.deadLetter, SyncReasonCodes.invalidPayload);
    }
    if (value.contains('unavailable') ||
        value.contains('network-request-failed') ||
        value.contains('network error') ||
        value.contains('offline')) {
      return const SyncErrorClassification(
          SyncFailureKind.retry, SyncReasonCodes.offline);
    }
    return const SyncErrorClassification(
        SyncFailureKind.retry, SyncReasonCodes.transientRemoteFailure);
  }
}
