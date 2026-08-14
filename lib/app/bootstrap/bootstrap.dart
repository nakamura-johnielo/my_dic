import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/app.dart';
import 'package:my_dic/app/bootstrap/app_dependencies.dart';
import 'package:my_dic/app/workflows/sync_trigger/application_lifecycle_effects.dart';
import 'package:my_dic/core/composition/data_di.dart';
import 'package:my_dic/core/infrastructure/database/shared_preferences/shared_preferences.dart';
import 'package:my_dic/app/bootstrap/session_composition.dart';
import 'package:my_dic/app/bootstrap/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_dic/features/word_status/port/presentation_dependencies.dart';
import 'package:my_dic/app/bootstrap/word_status_composition.dart';
import 'package:my_dic/integration/catalog_search/catalog_search_providers.dart';
import 'package:my_dic/app/bootstrap/quiz_composition.dart';
import 'package:my_dic/features/search/port/presentation_dependencies.dart';
import 'package:my_dic/features/quiz/port/presentation_dependencies.dart';
import 'package:my_dic/features/auth/port/presentation_dependencies.dart';
import 'package:my_dic/app/bootstrap/auth_composition.dart';
import 'package:my_dic/app/bootstrap/ranking_composition.dart';
import 'package:my_dic/app/bootstrap/word_detail_composition.dart';
import 'package:my_dic/features/ranking/port/presentation_dependencies.dart';
import 'package:my_dic/features/word_detail/port/presentation_dependencies.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key, this.bootstrapper, this.appBuilder});

  final AppBootstrapper? bootstrapper;
  final Widget Function()? appBuilder;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<AppDependencies> _dependencies;

  @override
  void initState() {
    super.initState();
    _dependencies =
        (widget.bootstrapper ?? _productionBootstrapper()).initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppDependencies>(
      future: _dependencies,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return BootstrapFailureApp(error: snapshot.error!);
        }
        if (!snapshot.hasData) {
          return const BootstrapLoadingApp();
        }
        return ProviderScope(
          overrides: [
            sharedPreferencesProvider
                .overrideWithValue(snapshot.data!.sharedPreferences),
            sessionScopeKeyProvider.overrideWith(resolveSessionScopeKey),
            searchReaderPortDependencyProvider.overrideWith(
              (ref) => ref.watch(searchReaderPortProvider),
            ),
            wordDetailPresentationDependenciesProvider.overrideWith(
              (ref) => WordDetailPresentationDependencies(
                reader: ref.watch(wordDetailReaderPortProvider),
              ),
            ),
            quizPortsDependencyProvider.overrideWith(
              (ref) => ref.watch(quizPortsProvider),
            ),
            wordStatusPortsDependencyProvider.overrideWith(
              (ref) => ref.watch(wordStatusPortsProvider),
            ),
            rankingPresentationDependenciesProvider.overrideWith(
              (ref) => RankingPresentationDependencies(
                ports: ref.watch(rankingPortsProvider),
              ),
            ),
            authCommandPortDependencyProvider.overrideWith(
              (ref) => ref.watch(authCommandPortProvider),
            ),
          ],
          child: AppReadinessGate(
            appBuilder: widget.appBuilder ?? () => const MyApp(),
          ),
        );
      },
    );
  }
}

AppBootstrapper _productionBootstrapper() => AppBootstrapper(
      initializeFirebase: () async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      },
      loadSharedPreferences: SharedPreferences.getInstance,
    );

final appReadinessProbeProvider = Provider<Future<void> Function()>((ref) {
  final database = ref.read(databaseProvider);
  return () => database.customSelect('SELECT 1').get();
});

final appReadinessProvider = FutureProvider<void>((ref) async {
  await ref.read(appReadinessProbeProvider)();
  ref.read(applicationLifecycleEffectsProvider);
});

class AppReadinessGate extends ConsumerWidget {
  const AppReadinessGate({super.key, required this.appBuilder});

  final Widget Function() appBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readiness = ref.watch(appReadinessProvider);
    return readiness.when(
      data: (_) => appBuilder(),
      loading: () => const BootstrapLoadingApp(),
      error: (error, _) => BootstrapFailureApp(error: error),
    );
  }
}

class BootstrapLoadingApp extends StatelessWidget {
  const BootstrapLoadingApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
}

class BootstrapFailureApp extends StatelessWidget {
  const BootstrapFailureApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('アプリの初期化に失敗しました。\n$error'),
            ),
          ),
        ),
      );
}
