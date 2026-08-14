import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/integration/session_lifecycle_workflow/session_epoch_coordinator.dart';
import 'package:my_dic/integration/session_lifecycle_workflow/session_fence_service.dart';
import 'package:my_dic/integration/session_lifecycle_workflow/auth_lifecycle_state.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/auth/port/auth.dart';
import 'package:my_dic/features/sync/port/sync_runner.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/sync_run_outcome.dart';

void main() {
  test('SessionScopeKey uses account scope and epoch value equality', () {
    const first = SessionScopeKey(accountScope: 'account-a', epoch: 7);
    const equal = SessionScopeKey(accountScope: 'account-a', epoch: 7);
    const newEpoch = SessionScopeKey(accountScope: 'account-a', epoch: 8);

    expect(first, equal);
    expect(first.hashCode, equal.hashCode);
    expect(first, isNot(newEpoch));
  });

  group('SessionEpochCoordinator', () {
    test('activates guest only from stable signed-out and keeps repeats stable',
        () {
      final fence = SessionFenceService();
      final coordinator = SessionEpochCoordinator(fence, _scheduler(fence));

      expect(
        coordinator.onLifecycleChanged(const AuthLifecycleState.initializing()),
        isNull,
      );
      final guest = coordinator.onLifecycleChanged(
        const AuthLifecycleState(phase: AuthLifecyclePhase.signedOut),
      );

      expect(guest!.accountScope, guestAccountScope);
      expect(
        coordinator.onLifecycleChanged(
          const AuthLifecycleState(phase: AuthLifecyclePhase.signedOut),
        ),
        guest,
      );
      expect(
          fence.isCurrent(
              accountId: guestAccountScope, sessionEpoch: guest.epoch),
          isTrue);
    });

    test('detaches intermediate scope and reissues same-account epoch', () {
      final fence = SessionFenceService();
      final coordinator = SessionEpochCoordinator(fence, _scheduler(fence));
      final ready = _ready('account-a');
      final first = coordinator.onLifecycleChanged(ready)!;

      expect(
        coordinator.onLifecycleChanged(AuthLifecycleState(
          phase: AuthLifecyclePhase.signingOut,
          auth: ready.auth,
        )),
        isNull,
      );
      expect(fence.isCurrent(accountId: 'account-a', sessionEpoch: first.epoch),
          isFalse);

      final guest = coordinator.onLifecycleChanged(
        const AuthLifecycleState(phase: AuthLifecyclePhase.signedOut),
      )!;
      final second = coordinator.onLifecycleChanged(ready)!;
      expect(second.accountScope, 'account-a');
      expect(second.epoch, greaterThan(first.epoch));
      expect(second.epoch, greaterThan(guest.epoch));
      expect(
          fence.isCurrent(accountId: 'account-a', sessionEpoch: second.epoch),
          isTrue);
    });

    test('switching accounts issues one matching presentation and fence epoch',
        () {
      final fence = SessionFenceService();
      final coordinator = SessionEpochCoordinator(fence, _scheduler(fence));
      coordinator.onLifecycleChanged(_ready('account-a'));
      final b = coordinator.onLifecycleChanged(_ready('account-b'))!;

      expect(fence.isCurrent(accountId: 'account-a', sessionEpoch: 1), isFalse);
      expect(fence.isCurrent(accountId: b.accountScope, sessionEpoch: b.epoch),
          isTrue);
      expect(coordinator.activeScope, b);
    });
  });
}

AuthLifecycleState _ready(String id) => AuthLifecycleState(
      phase: AuthLifecyclePhase.ready,
      auth: AuthIdentity(accountId: id, email: '$id@example.test'),
    );

class _Runner implements SyncRunner {
  @override
  Future<SyncRunOutcome> foreground(SyncContext context) async =>
      SyncRunOutcome.success;
  @override
  void cancelRetryForAccount(String accountId) {}
  @override
  void dispose() {}
}

SyncRunner _scheduler(SessionFenceService fence) => _Runner();
