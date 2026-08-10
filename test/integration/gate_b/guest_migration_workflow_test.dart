import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/bootstrap/guest_migration_composition.dart';
import 'package:my_dic/app/guest_migration/guest_data_summary.dart';
import 'package:my_dic/app/guest_migration/presentation/guest_migration_prompt.dart';
import 'package:my_dic/app/routing/router.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/session/session_scope_provider.dart';
import 'package:my_dic/features/auth/port/app_auth.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/sync_run_outcome.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

/// Gate B cross-layer workflow acceptance. Real Drift rollback/outbox behavior
/// is exercised by the paired migration use-case unit; this test controls the
/// app workflow's session and public composition boundary.
void main() {
  testWidgets('late old-session detection cannot open or migrate',
      (tester) async {
    final workflow = _Workflow(deferredDetect: true);
    final harness = await _pump(tester, workflow);

    harness.scope.state =
        const SessionScopeKey(accountScope: 'account-b', epoch: 2);
    harness.session.state = _ready('account-b');
    workflow.completeDetect(_summary);
    await tester.pumpAndSettle();

    // A fresh account-B prompt may legitimately appear; the old account-A
    // completion must never migrate account A.
    expect(workflow.migrations, isEmpty);
    harness.dispose();
  });

  testWidgets('retryScheduled has no UI retry', (tester) async {
    final workflow = _Workflow(outcomes: [SyncRunOutcome.retryScheduled]);
    final harness = await _pump(tester, workflow);

    await tester.tap(find.descendant(
        of: find.byType(AlertDialog), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();
    expect(find.text('Migration completed. Sync will retry automatically.'),
        findsOneWidget);
    expect(find.byType(SnackBarAction), findsNothing);

    harness.dispose();
  });

  testWidgets('non-retryable post-sync failure exposes one UI retry',
      (tester) async {
    final harness =
        await _pump(tester, _Workflow(outcomes: [SyncRunOutcome.failure]));
    await tester.tap(find.descendant(
        of: find.byType(AlertDialog), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();
    expect(find.text('Migration completed, but sync needs attention.'),
        findsOneWidget);
    expect(find.byType(SnackBarAction), findsOneWidget);
    harness.dispose();
  });
}

const _summary = GuestDataSummary(
  espJpnWordStatusCount: 1,
  jpnEspWordStatusCount: 0,
  myWordCount: 0,
  myWordStatusCount: 0,
  userProfileCount: 0,
);

class _Harness {
  _Harness(this.container, this.session, this.scope);
  final ProviderContainer container;
  final StateController<AppSession> session;
  final StateController<SessionScopeKey?> scope;
  void dispose() => container.dispose();
}

Future<_Harness> _pump(WidgetTester tester, _Workflow workflow) async {
  const initial = SessionScopeKey(accountScope: 'account-a', epoch: 1);
  final session = StateProvider<AppSession>((_) => _ready('account-a'));
  final scope = StateProvider<SessionScopeKey?>((_) => initial);
  final key = GlobalKey<NavigatorState>();
  late final ProviderContainer container;
  container = ProviderContainer(overrides: [
    appSessionProvider.overrideWith((ref) => ref.watch(session)),
    sessionScopeKeyProvider.overrideWith((ref) => ref.watch(scope)),
    rootNavigatorKeyProvider.overrideWithValue(key),
    guestMigrationWorkflowDependenciesProvider.overrideWithValue(
      GuestMigrationWorkflowDependencies(
        detect: workflow.detect,
        migrate: workflow.migrate,
        sync: workflow.sync,
        isCurrent: (scopeKey) => container.read(scope) == scopeKey,
      ),
    ),
  ]);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
        navigatorKey: key, home: const Scaffold(body: GuestMigrationPrompt())),
  ));
  await tester.pumpAndSettle();
  return _Harness(container, container.read(session.notifier),
      container.read(scope.notifier));
}

AppSessionReady _ready(String id) =>
    AppSessionReady(AppAuth(accountId: id, isAuthenticated: true), AppUser());

class _Workflow {
  _Workflow({this.deferredDetect = false, List<SyncRunOutcome>? outcomes})
      : _outcomes = outcomes ?? [SyncRunOutcome.success];
  final bool deferredDetect;
  final List<SyncRunOutcome> _outcomes;
  final migrations = <(String, int)>[];
  final _detect = Completer<GuestDataSummary>();

  Future<GuestDataSummary> detect() =>
      deferredDetect ? _detect.future : Future.value(_summary);
  void completeDetect(GuestDataSummary summary) => _detect.complete(summary);
  Future<void> migrate(String account, int epoch) async =>
      migrations.add((account, epoch));
  Future<SyncRunOutcome> sync(SyncContext _) async => _outcomes.removeAt(0);
}
