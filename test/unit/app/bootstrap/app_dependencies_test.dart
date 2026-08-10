import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/bootstrap/bootstrap.dart';
import 'package:my_dic/app/bootstrap/app_dependencies.dart';
import 'package:my_dic/app/bootstrap/legacy_sync_preferences_cleanup.dart';
import 'package:my_dic/app/workflows/sync_trigger/application_lifecycle_effects.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('initializes environment once and returns loaded preferences', () async {
    var firebaseCalls = 0;
    var preferencesCalls = 0;
    final preferences = await SharedPreferences.getInstance();
    final bootstrapper = AppBootstrapper(
      initializeFirebase: () async {
        firebaseCalls++;
      },
      loadSharedPreferences: () async {
        preferencesCalls++;
        return preferences;
      },
    );

    final dependencies = await bootstrapper.initialize();

    expect(firebaseCalls, 1);
    expect(preferencesCalls, 1);
    expect(dependencies.sharedPreferences, same(preferences));
  });

  test('does not load preferences when Firebase initialization fails',
      () async {
    var preferencesCalls = 0;
    final bootstrapper = AppBootstrapper(
      initializeFirebase: () async => throw StateError('firebase failed'),
      loadSharedPreferences: () async {
        preferencesCalls++;
        return SharedPreferences.getInstance();
      },
    );

    await expectLater(bootstrapper.initialize(), throwsStateError);
    expect(preferencesCalls, 0);
  });

  test('continues bootstrap when legacy cleanup fails and retries next launch',
      () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('lastSync_wordStatus', 123);
    final failingBootstrapper = AppBootstrapper(
      initializeFirebase: () async {},
      loadSharedPreferences: () async => preferences,
      legacySyncPreferencesCleanup: const _FailingLegacyCleanup(),
    );

    await failingBootstrapper.initialize();

    expect(preferences.containsKey('lastSync_wordStatus'), isTrue);
    expect(
      preferences.containsKey(LegacySyncPreferencesCleanup.completionMarker),
      isFalse,
    );

    await AppBootstrapper(
      initializeFirebase: () async {},
      loadSharedPreferences: () async => preferences,
    ).initialize();

    expect(preferences.containsKey('lastSync_wordStatus'), isFalse);
    expect(
      preferences.containsKey(LegacySyncPreferencesCleanup.completionMarker),
      isTrue,
    );
  });

  testWidgets('shows an error UI when environment initialization fails',
      (tester) async {
    final bootstrapper = AppBootstrapper(
      initializeFirebase: () async => throw StateError('firebase failed'),
      loadSharedPreferences: SharedPreferences.getInstance,
    );

    await tester.pumpWidget(AppBootstrap(bootstrapper: bootstrapper));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.textContaining('firebase failed'), findsOneWidget);
  });

  testWidgets(
      'runs the readiness probe and lifecycle effects once across rebuilds',
      (tester) async {
    var probeCalls = 0;
    var lifecycleEffectRegistrations = 0;
    late VoidCallback rebuild;
    final preferences = await SharedPreferences.getInstance();
    final bootstrapper = AppBootstrapper(
      initializeFirebase: () async {},
      loadSharedPreferences: () async => preferences,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appReadinessProbeProvider.overrideWithValue(() async {
            probeCalls++;
          }),
          applicationLifecycleEffectsProvider.overrideWith((ref) {
            lifecycleEffectRegistrations++;
          }),
        ],
        child: StatefulBuilder(
          builder: (context, setState) {
            rebuild = () => setState(() {});
            return AppBootstrap(
              bootstrapper: bootstrapper,
              appBuilder: () => const MaterialApp(home: Text('My app')),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    rebuild();
    await tester.pumpAndSettle();

    expect(probeCalls, 1);
    expect(lifecycleEffectRegistrations, 1);
    expect(find.text('My app'), findsOneWidget);
  });

  testWidgets(
      'shows the failure app without constructing MyApp when readiness fails',
      (tester) async {
    var appBuilderCalls = 0;
    final preferences = await SharedPreferences.getInstance();
    final bootstrapper = AppBootstrapper(
      initializeFirebase: () async {},
      loadSharedPreferences: () async => preferences,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appReadinessProbeProvider.overrideWithValue(
            () async => throw StateError('database unavailable'),
          ),
        ],
        child: AppBootstrap(
          bootstrapper: bootstrapper,
          appBuilder: () {
            appBuilderCalls++;
            return const MaterialApp(home: Text('My app'));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BootstrapFailureApp), findsOneWidget);
    expect(find.textContaining('database unavailable'), findsOneWidget);
    expect(find.text('My app'), findsNothing);
    expect(appBuilderCalls, 0);
  });
}

class _FailingLegacyCleanup extends LegacySyncPreferencesCleanup {
  const _FailingLegacyCleanup();

  @override
  Future<bool> run(LegacySyncPreferencesStore preferences) async => false;
}
