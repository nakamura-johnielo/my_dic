import 'package:my_dic/features/sync/port/sync_reason_codes.dart';

enum SyncFailureKind { retry, pause, deadLetter }

class SyncErrorClassification {
  const SyncErrorClassification(this.kind, this.code);
  final SyncFailureKind kind;
  final String code;
  bool get retryable => kind == SyncFailureKind.retry;
}

/// 機能アダプターは Firebase／HTTP 実装エラーをキュー状態機械へ漏らさず、これらの安定した
/// エラーコードのいずれかを公開する必要があります。
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
