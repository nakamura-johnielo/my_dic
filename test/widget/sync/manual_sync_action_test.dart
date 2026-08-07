import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/app/presentation/sync/manual_sync_action.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
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
  _Handler({required this.result, this.block = false});

  @override
  SyncDataset get dataset => SyncDataset.myWords;

  final DatasetSyncResult result;
  final bool block;
  final started = Completer<void>();
  final release = Completer<void>();
  int calls = 0;

  @override
  Future<DatasetSyncResult> run(SyncContext context) async {
    calls++;
    started.complete();
    if (block) await release.future;
    return result;
  }
}

AppSessionReady _readySession() => AppSessionReady(
      AppAuth(accountId: 'account-a', isAuthenticated: true),
      AppUser(),
    );

SyncScheduler _schedulerFor(_Handler handler, InMemorySessionFence fence) =>
    SyncScheduler(
      SyncEngine(
        handlers: DatasetHandlerRegistry([handler]),
        datasetPlan: const DatasetPlan([SyncDataset.myWords]),
        sessionFence: fence,
        singleFlightCoordinator: SingleFlightCoordinator(),
      ),
    );

Future<void> _pumpAction(
  WidgetTester tester, {
  required AppSession session,
  required InMemorySessionFence fence,
  required SyncScheduler scheduler,
}) =>
    tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSessionProvider.overrideWithValue(session),
          syncSessionFenceProvider.overrideWithValue(fence),
          syncSchedulerProvider.overrideWithValue(scheduler),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(actions: [ManualSyncAction()]),
          ),
        ),
      ),
    );

void main() {
  testWidgets('is available only for a ready session', (tester) async {
    final fence = InMemorySessionFence()..setCurrent('account-a', 1);
    final scheduler = _schedulerFor(
      _Handler(
        result: const DatasetSyncResult.success(pushedCount: 0, pulledCount: 0),
      ),
      fence,
    );

    await _pumpAction(
      tester,
      session: const AppSessionSignedOut(),
      fence: fence,
      scheduler: scheduler,
    );
    expect(find.byTooltip('Sync now'), findsNothing);

    await _pumpAction(
      tester,
      session: _readySession(),
      fence: fence,
      scheduler: scheduler,
    );
    expect(find.byTooltip('Sync now'), findsOneWidget);
  });

  testWidgets('shows a spinner and suppresses a second tap while running',
      (tester) async {
    final fence = InMemorySessionFence()..setCurrent('account-a', 1);
    final handler = _Handler(
      block: true,
      result: const DatasetSyncResult.success(pushedCount: 1, pulledCount: 0),
    );
    await _pumpAction(
      tester,
      session: _readySession(),
      fence: fence,
      scheduler: _schedulerFor(handler, fence),
    );

    await tester.tap(find.byTooltip('Sync now'));
    await handler.started.future;
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byTooltip('Sync now'));
    await tester.pump();
    expect(handler.calls, 1);

    handler.release.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('shows a success notice after a completed sync', (tester) async {
    final fence = InMemorySessionFence()..setCurrent('account-a', 1);
    final handler = _Handler(
      result: const DatasetSyncResult.success(pushedCount: 1, pulledCount: 0),
    );
    await _pumpAction(
      tester,
      session: _readySession(),
      fence: fence,
      scheduler: _schedulerFor(handler, fence),
    );

    await tester.tap(find.byTooltip('Sync now'));
    await tester.pumpAndSettle();

    expect(find.text('Sync complete.'), findsOneWidget);
  });

  testWidgets('does not show a notice for a cancelled report', (tester) async {
    final fence = InMemorySessionFence()..setCurrent('account-a', 1);
    final handler = _Handler(
      result: const DatasetSyncResult.cancelled('caller_cancelled'),
    );
    await _pumpAction(
      tester,
      session: _readySession(),
      fence: fence,
      scheduler: _schedulerFor(handler, fence),
    );

    await tester.tap(find.byTooltip('Sync now'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
  });
}
