import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/application/effects/auth_effect_provider.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/features/sync/di.dart';

/// Owns application-wide effects independently from widget rebuilds.
///
/// New SyncEngine triggers will be added here when a production dataset handler
/// is introduced. Until then this retains the existing legacy auto-sync path.
final applicationLifecycleEffectsProvider = Provider<void>((ref) {
  final observer = _ApplicationLifecycleObserver();
  WidgetsBinding.instance.addObserver(observer);
  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(observer);
  });

  ref.watch(authEffectProvider);
  ref.watch(autoSyncProvider);
  ref.read(syncSchedulerProvider);
});

class _ApplicationLifecycleObserver with WidgetsBindingObserver {}
