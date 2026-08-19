import 'package:my_dic/core/presentation/state/ui_effect.dart';

/// アプリバー同期操作のための、一時的でUIに安全な状態。
///
/// [SyncReport]、アカウント識別子、カーソル、変更データを意図的に保持しません。
/// コントローラーがレポートをワンショット通知に変換します。
class ManualSyncUiState {
  const ManualSyncUiState({
    this.isSyncing = false,
    this.pendingEffect,
  });

  final bool isSyncing;
  final UiEffectEnvelope<UiEffect>? pendingEffect;

  ManualSyncUiState copyWith({
    bool? isSyncing,
    UiEffectEnvelope<UiEffect>? pendingEffect,
    bool clearEffect = false,
  }) =>
      ManualSyncUiState(
        isSyncing: isSyncing ?? this.isSyncing,
        pendingEffect: clearEffect ? null : pendingEffect ?? this.pendingEffect,
      );
}
