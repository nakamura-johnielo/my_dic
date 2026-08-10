import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/presentation/sync/manual_sync_action.dart';
import 'package:my_dic/app/presentation/sync/manual_sync_controller.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/session/session_scope_provider.dart';
import 'package:my_dic/features/auth/port/app_auth.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/session_fence.dart';
import 'package:my_dic/features/sync/port/sync_run_outcome.dart';
import 'package:my_dic/features/sync/port/sync_runner.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

void main() {
  testWidgets('is available only for a ready session', (tester) async {
    await _pumpAction(tester, session: const AppSessionSignedOut());
    expect(find.byTooltip('Sync now'), findsNothing);

    await _pumpAction(tester, session: _readySession());
    expect(find.byTooltip('Sync now'), findsOneWidget);
  });

  testWidgets('shows a spinner and suppresses a second tap while running',
      (tester) async {
    final runner = _Runner(block: true);
    await _pumpAction(tester, session: _readySession(), runner: runner);

    await tester.tap(find.byTooltip('Sync now'));
    await runner.started.future;
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byTooltip('Sync now'));
    await tester.pump();
    expect(runner.calls, 1);

    runner.release.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('shows a success notice after a completed sync', (tester) async {
    await _pumpAction(tester, session: _readySession());

    await tester.tap(find.byTooltip('Sync now'));
    await tester.pumpAndSettle();

    expect(find.text('Sync complete.'), findsOneWidget);
  });

  testWidgets('does not show a notice for a cancelled run', (tester) async {
    await _pumpAction(
      tester,
      session: _readySession(),
      runner: _Runner(outcome: SyncRunOutcome.cancelled),
    );

    await tester.tap(find.byTooltip('Sync now'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
  });
}

AppSessionReady _readySession() => AppSessionReady(
      AppAuth(accountId: 'account-a', isAuthenticated: true),
      AppUser(),
    );

Future<void> _pumpAction(
  WidgetTester tester, {
  required AppSession session,
  _Runner? runner,
}) {
  final syncRunner = runner ?? _Runner();
  const scope = SessionScopeKey(accountScope: 'account-a', epoch: 1);
  return tester.pumpWidget(ProviderScope(
    overrides: [
      appSessionProvider.overrideWithValue(session),
      sessionScopeKeyProvider.overrideWithValue(
        session is AppSessionReady ? scope : null,
      ),
      manualSyncControllerProvider.overrideWith(
        (ref) => ManualSyncController(
          scheduler: syncRunner,
          sessionFence: const _Fence(),
          currentScope: () => ref.read(sessionScopeKeyProvider),
          initialSession: session,
        ),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(appBar: AppBar(actions: const [ManualSyncAction()])),
    ),
  ));
}

class _Runner implements SyncRunner {
  _Runner({this.outcome = SyncRunOutcome.success, this.block = false});

  final SyncRunOutcome outcome;
  final bool block;
  final started = Completer<void>();
  final release = Completer<void>();
  int calls = 0;

  @override
  Future<SyncRunOutcome> foreground(SyncContext context) async {
    calls++;
    if (!started.isCompleted) started.complete();
    if (block) await release.future;
    return outcome;
  }

  @override
  void cancelRetryForAccount(String accountId) {}

  @override
  void dispose() {}
}

class _Fence implements SessionFence {
  const _Fence();

  @override
  bool isCurrent({required String accountId, required int sessionEpoch}) =>
      accountId == 'account-a' && sessionEpoch == 1;
}
