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
import 'package:my_dic/features/sync/port/sync_run_outcome.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

void main() {
  testWidgets('detection failure shows Retry and retries current scope',
      (tester) async {
    final workflow = _Workflow()
      ..detectResults.add(StateError('temporary'))
      ..detectResults.add(_summary);
    final harness = await _pump(tester, workflow);

    expect(find.text('Could not check guest data.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(workflow.detectCalls, 2);
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextButton),
    ));
    await tester.pumpAndSettle();
    harness.dispose();
  });

  testWidgets('account switch closes stale dialog and queues latest scope',
      (tester) async {
    final workflow = _Workflow()
      ..detectResults.add(_summary)
      ..detectResults.add(_summary);
    final harness = await _pump(tester, workflow);
    expect(find.byType(AlertDialog), findsOneWidget);

    harness.scope.state =
        const SessionScopeKey(accountScope: 'account-b', epoch: 2);
    harness.session.state = _ready('account-b');
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(workflow.detectCalls, greaterThanOrEqualTo(1));
    harness.dispose();
  });

  testWidgets('retryable and non-retryable post-sync outcomes differ',
      (tester) async {
    final workflow = _Workflow()
      ..detectResults.add(_summary)
      ..outcomes.add(SyncRunOutcome.retryScheduled);
    final harness = await _pump(tester, workflow);
    await tester.tap(find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(FilledButton),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Migration completed. Sync will retry automatically.'),
        findsOneWidget);

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
  const initialScope = SessionScopeKey(accountScope: 'account-a', epoch: 1);
  final session = StateProvider<AppSession>((_) => _ready('account-a'));
  final scope = StateProvider<SessionScopeKey?>((_) => initialScope);
  final navigatorKey = GlobalKey<NavigatorState>();
  late final ProviderContainer container;
  container = ProviderContainer(overrides: [
    appSessionProvider.overrideWith((ref) => ref.watch(session)),
    sessionScopeKeyProvider.overrideWith((ref) => ref.watch(scope)),
    rootNavigatorKeyProvider.overrideWithValue(navigatorKey),
    guestMigrationWorkflowDependenciesProvider.overrideWithValue(
      GuestMigrationWorkflowDependencies(
        detect: workflow.detect,
        migrate: workflow.migrate,
        sync: workflow.sync,
        isCurrent: (key) => container.read(scope) == key,
      ),
    ),
  ]);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      navigatorKey: navigatorKey,
      home: const Scaffold(body: GuestMigrationPrompt()),
    ),
  ));
  await tester.pumpAndSettle();
  return _Harness(container, container.read(session.notifier),
      container.read(scope.notifier));
}

AppSessionReady _ready(String accountId) => AppSessionReady(
      AppAuth(accountId: accountId, isAuthenticated: true),
      AppUser(),
    );

class _Workflow {
  final detectResults = <Object>[];
  final outcomes = <SyncRunOutcome>[];
  int detectCalls = 0;

  Future<GuestDataSummary> detect() {
    detectCalls++;
    final next = detectResults.removeAt(0);
    return next is GuestDataSummary ? Future.value(next) : Future.error(next);
  }

  Future<void> migrate(String accountId, int epoch) async {}

  Future<SyncRunOutcome> sync(SyncContext _) async =>
      outcomes.isEmpty ? SyncRunOutcome.success : outcomes.removeAt(0);
}
