import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/sync/application/cancellation_token.dart';
import 'package:my_dic/features/sync/application/in_memory_session_fence.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/report/sync_reason_codes.dart';
import 'package:my_dic/features/sync/application/sync_execution_guard.dart';

void main() {
  SyncContext context(CancellationToken token) => SyncContext(
        accountId: 'account-a',
        sessionEpoch: 1,
        reason: 'test',
        cancellation: token,
      );

  test('rejects every subsequent handler side effect after an epoch change',
      () {
    final fence = InMemorySessionFence()..setCurrent('account-a', 1);
    final guard = SyncExecutionGuard(fence);
    final token = CancellationToken();

    expect(guard.canContinue(context(token)), isTrue);
    fence.setCurrent('account-a', 2);

    expect(guard.canContinue(context(token)), isFalse);
    expect(guard.cancellationReason(context(token)),
        SyncReasonCodes.sessionChanged);
  });

  test('rejects a cancelled context even while its epoch is current', () {
    final fence = InMemorySessionFence()..setCurrent('account-a', 1);
    final token = CancellationToken()..cancel('sign out');

    expect(SyncExecutionGuard(fence).canContinue(context(token)), isFalse);
    expect(SyncExecutionGuard(fence).cancellationReason(context(token)),
        SyncReasonCodes.callerCancelled);
  });
}
