import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/feature_composition/sync_composition.dart';
import 'package:my_dic/integration/session_lifecycle_workflow/session_epoch_coordinator.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/session/session_scope_provider.dart';
import 'package:my_dic/integration/session_lifecycle_workflow/auth_lifecycle_provider.dart';

export 'package:my_dic/core/session/session_scope_provider.dart'
    show sessionScopeKeyProvider;

/// 1つのコンテナーが1つのコーディネーター、ひいては1つのエポックカウンターだけを所有します。
final sessionEpochCoordinatorProvider =
    Provider<SessionEpochCoordinator>((ref) {
  final coordinator = SessionEpochCoordinator(
    ref.watch(syncSessionFenceProvider),
    ref.watch(syncRunnerProvider),
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

/// アクティブなプレゼンテーション/クエリの識別子。`null` は中間ライフサイクルフェーズを
/// 意味し、呼び出し元はゲストとして扱うのではなく切り離す必要があります。
SessionScopeKey? resolveSessionScopeKey(Ref ref) {
  final lifecycle = ref.watch(authLifecycleProvider);
  return ref
      .watch(sessionEpochCoordinatorProvider)
      .onLifecycleChanged(lifecycle);
}

/// 単一のセッションコーディネーターリスナーを設定します。コーディネーター自体は
/// [sessionEpochCoordinatorProvider] が所有するため、すべての利用側が同じエポック列を観測します。
final sessionFenceEffectProvider = Provider<void>((ref) {
  ref.watch(sessionScopeKeyProvider);
});
