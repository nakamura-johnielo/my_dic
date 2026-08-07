import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/presentation/sync/manual_sync_controller.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/features/sync/application/dataset_handler_registry.dart';
import 'package:my_dic/features/sync/application/in_memory_session_fence.dart';
import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/policy/dataset_plan.dart';
import 'package:my_dic/features/sync/application/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/application/single_flight_coordinator.dart';
import 'package:my_dic/features/sync/application/sync_engine.dart';
import 'package:my_dic/features/sync/application/sync_scheduler.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';

class _Handler implements DatasetSyncHandler {
  _Handler({this.waitForRelease = false});

  @override
  SyncDataset get dataset => SyncDataset.myWords;

  final bool waitForRelease;
  final started = Completer<void>();
  final release = Completer<void>();
  SyncContext? receivedContext;
  int calls = 0;

  @override
  Future<DatasetSyncResult> run(SyncContext context) async {
    calls++;
    receivedContext = context;
    started.complete();
    if (waitForRelease) await release.future;
    return const DatasetSyncResult.success(pushedCount: 1, pulledCount: 0);
  }
}

AppSessionReady _ready(String accountId) => AppSessionReady(
      AppAuth(accountId: accountId, isAuthenticated: true),
      AppUser(),
    );

ManualSyncController _controller(
  _Handler handler,
  InMemorySessionFence fence,
  AppSession initialSession,
) {
  final engine = SyncEngine(
    handlers: DatasetHandlerRegistry([handler]),
    datasetPlan: const DatasetPlan([SyncDataset.myWords]),
    sessionFence: fence,
    singleFlightCoordinator: SingleFlightCoordinator(),
  );
  return ManualSyncController(
    scheduler: SyncScheduler(engine),
    sessionFence: fence,
    initialSession: initialSession,
  );
}

void main() {
  test('builds a manual context and exposes a consumable safe notice',
      () async {
    final session = _ready('account-a');
    final fence = InMemorySessionFence()..setCurrent('account-a', 4);
    final handler = _Handler();
    final controller = _controller(handler, fence, session);

    await controller.sync(session);

    expect(handler.receivedContext?.accountId, 'account-a');
    expect(handler.receivedContext?.sessionEpoch, 4);
    expect(handler.receivedContext?.reason, 'manual');
    final effect = controller.state.pendingEffect;
    expect(effect?.effect, isA<UiNoticeEffect>());
    expect((effect!.effect as UiNoticeEffect).message, 'Sync complete.');
    controller.consumeEffect(effect.id);
    expect(controller.state.pendingEffect, isNull);
    controller.dispose();
  });

  test('deduplicates taps while a sync is in progress', () async {
    final session = _ready('account-a');
    final fence = InMemorySessionFence()..setCurrent('account-a', 1);
    final handler = _Handler(waitForRelease: true);
    final controller = _controller(handler, fence, session);

    final first = controller.sync(session);
    await handler.started.future;
    final second = controller.sync(session);
    handler.release.complete();
    await Future.wait([first, second]);

    expect(handler.calls, 1);
    controller.dispose();
  });

  test('suppresses a completed notice after the ready session changes',
      () async {
    final session = _ready('account-a');
    final fence = InMemorySessionFence()..setCurrent('account-a', 1);
    final handler = _Handler(waitForRelease: true);
    final controller = _controller(handler, fence, session);

    final sync = controller.sync(session);
    await handler.started.future;
    controller.onSessionChanged(_ready('account-b'));
    handler.release.complete();
    await sync;

    expect(controller.state.isSyncing, isFalse);
    expect(controller.state.pendingEffect, isNull);
    controller.dispose();
  });
}
