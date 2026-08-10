import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/workflows/session_lifecycle/session_epoch_coordinator.dart';
import 'package:my_dic/app/workflows/session_lifecycle/auth_lifecycle_state.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/auth/port/app_auth.dart';
import 'package:my_dic/features/sync/application/dataset_handler_registry.dart';
import 'package:my_dic/features/sync/application/in_memory_session_fence.dart';
import 'package:my_dic/features/sync/application/policy/dataset_plan.dart';
import 'package:my_dic/features/sync/application/single_flight_coordinator.dart';
import 'package:my_dic/features/sync/application/sync_engine.dart';
import 'package:my_dic/features/sync/application/sync_scheduler.dart';

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
      final fence = InMemorySessionFence();
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
      expect(fence.epochFor(guestAccountScope), guest.epoch);
    });

    test('detaches intermediate scope and reissues same-account epoch', () {
      final fence = InMemorySessionFence();
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
      expect(fence.epochFor('account-a'), isNull);

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
      final fence = InMemorySessionFence();
      final coordinator = SessionEpochCoordinator(fence, _scheduler(fence));
      coordinator.onLifecycleChanged(_ready('account-a'));
      final b = coordinator.onLifecycleChanged(_ready('account-b'))!;

      expect(fence.epochFor('account-a'), isNull);
      expect(fence.epochFor(b.accountScope), b.epoch);
      expect(coordinator.activeScope, b);
    });

  });
}

AuthLifecycleState _ready(String id) => AuthLifecycleState(
      phase: AuthLifecyclePhase.ready,
      auth: AppAuth(accountId: id, email: '$id@example.test'),
    );

SyncScheduler _scheduler(InMemorySessionFence fence) => SyncScheduler(
      SyncEngine(
        handlers: DatasetHandlerRegistry(const []),
        datasetPlan: DatasetPlan.localFirst,
        sessionFence: fence,
        singleFlightCoordinator: SingleFlightCoordinator(),
      ),
    );
