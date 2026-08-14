import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/presentation/sync/manual_sync_controller.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/auth/port/auth.dart';
import 'package:my_dic/features/sync/internal/application/in_memory_session_fence.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/sync_run_outcome.dart';
import 'package:my_dic/features/sync/port/sync_runner.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

class _Handler implements SyncRunner {
  _Handler({this.waitForRelease = false});

  final bool waitForRelease;
  final started = Completer<void>();
  final release = Completer<void>();
  SyncContext? receivedContext;
  int calls = 0;

  @override
  Future<SyncRunOutcome> foreground(SyncContext context) async {
    calls++;
    receivedContext = context;
    started.complete();
    if (waitForRelease) await release.future;
    return SyncRunOutcome.success;
  }

  @override
  void cancelRetryForAccount(String accountId) {}
  @override
  void dispose() {}
}

AppSessionReady _ready(String accountId) => AppSessionReady(
      AuthIdentity(accountId: accountId, emailVerified: true),
      AppUser(),
    );

ManualSyncController _controller(
  _Handler handler,
  InMemorySessionFence fence,
  AppSession initialSession,
) {
  return ManualSyncController(
    scheduler: handler,
    sessionFence: fence,
    currentScope: () => SessionScopeKey(
        accountScope: initialSession.accountIdOrNull!,
        epoch: fence.epochFor(initialSession.accountIdOrNull!)!),
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
