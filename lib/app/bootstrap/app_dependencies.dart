import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_dic/app/bootstrap/legacy_sync_preferences_cleanup.dart';

/// ProviderScopeが存在する前に作成する必要がある依存関係。
///
/// DriftやGoRouterのような長寿命で破棄可能なリソースは、意図的にここに置きません。
/// 代わりに、それらのRiverpodプロバイダーがライフサイクルを所有します。
class AppDependencies {
  const AppDependencies({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;
}

typedef FirebaseInitializer = Future<void> Function();
typedef SharedPreferencesLoader = Future<SharedPreferences> Function();

/// プロセスレベルの環境初期化をアプリ起動ごとに一度だけ実行します。
class AppBootstrapper {
  const AppBootstrapper({
    required FirebaseInitializer initializeFirebase,
    required SharedPreferencesLoader loadSharedPreferences,
    LegacySyncPreferencesCleanup legacySyncPreferencesCleanup =
        const LegacySyncPreferencesCleanup(),
  })  : _initializeFirebase = initializeFirebase,
        _loadSharedPreferences = loadSharedPreferences,
        _legacySyncPreferencesCleanup = legacySyncPreferencesCleanup;

  final FirebaseInitializer _initializeFirebase;
  final SharedPreferencesLoader _loadSharedPreferences;
  final LegacySyncPreferencesCleanup _legacySyncPreferencesCleanup;

  Future<AppDependencies> initialize() async {
    await _initializeFirebase();
    final sharedPreferences = await _loadSharedPreferences();
    await _legacySyncPreferencesCleanup.run(
      SharedPreferencesLegacySyncPreferencesStore(sharedPreferences),
    );
    return AppDependencies(sharedPreferences: sharedPreferences);
  }
}
