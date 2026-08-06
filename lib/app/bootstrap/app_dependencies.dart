import 'package:shared_preferences/shared_preferences.dart';

/// Dependencies that must be created before a ProviderScope exists.
///
/// Long-lived, disposable resources (such as Drift and GoRouter) intentionally
/// do not belong here; their Riverpod providers own their lifecycle instead.
class AppDependencies {
  const AppDependencies({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;
}

typedef FirebaseInitializer = Future<void> Function();
typedef SharedPreferencesLoader = Future<SharedPreferences> Function();

/// Runs process-level environment initialization exactly once per app start.
class AppBootstrapper {
  const AppBootstrapper({
    required FirebaseInitializer initializeFirebase,
    required SharedPreferencesLoader loadSharedPreferences,
  })  : _initializeFirebase = initializeFirebase,
        _loadSharedPreferences = loadSharedPreferences;

  final FirebaseInitializer _initializeFirebase;
  final SharedPreferencesLoader _loadSharedPreferences;

  Future<AppDependencies> initialize() async {
    await _initializeFirebase();
    final sharedPreferences = await _loadSharedPreferences();
    return AppDependencies(sharedPreferences: sharedPreferences);
  }
}
