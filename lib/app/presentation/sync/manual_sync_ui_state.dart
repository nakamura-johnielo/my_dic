import 'package:my_dic/core/presentation/state/ui_effect.dart';

/// Ephemeral, UI-safe state for the app-bar sync action.
///
/// Deliberately does not retain a [SyncReport], account identifier, cursor, or
/// any mutation data. The controller converts reports to a one-shot notice.
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
