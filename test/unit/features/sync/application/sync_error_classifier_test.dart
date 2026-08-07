import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/sync/application/policy/sync_error_classifier.dart';
import 'package:my_dic/features/sync/application/report/sync_reason_codes.dart';

void main() {
  const classifier = SyncErrorClassifier();

  test('classifies known offline transport failures as retryable', () {
    final result = classifier.classify(StateError('Firebase unavailable'));

    expect(result.kind, SyncFailureKind.retry);
    expect(result.code, SyncReasonCodes.offline);
  });

  test('keeps authentication and invalid payload failures distinct', () {
    final auth = classifier.classify(StateError('permission-denied'));
    final invalid = classifier.classify(StateError('invalid-argument'));

    expect(auth.kind, SyncFailureKind.pause);
    expect(auth.code, SyncReasonCodes.authRequired);
    expect(invalid.kind, SyncFailureKind.deadLetter);
    expect(invalid.code, SyncReasonCodes.invalidPayload);
  });

  test('classifies unknown remote failures as transient and retryable', () {
    final result = classifier.classify(StateError('backend overloaded'));

    expect(result.kind, SyncFailureKind.retry);
    expect(result.code, SyncReasonCodes.transientRemoteFailure);
  });
}
