import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/ranking/internal/presentation/ui_model/ranking_ui_model.dart';
import 'package:my_dic/features/ranking/internal/presentation/view_model/new_ranking_view_model.dart';
import 'package:my_dic/features/ranking/port/composition_contract.dart';

/// 内部プレゼンテーション識別子。ポートは同一性で比較するため、フェイク機能が
/// ランタイム機能と状態を共有することはない。
final class RankingPresentationKey {
  const RankingPresentationKey({required this.scope, required this.ports});

  final SessionScopeKey scope;
  final RankingPorts ports;

  @override
  bool operator ==(Object other) =>
      other is RankingPresentationKey &&
      scope == other.scope &&
      identical(ports, other.ports);

  @override
  int get hashCode => Object.hash(scope, identityHashCode(ports));
}

final rankingViewModelProvider = StateNotifierProvider.autoDispose
    .family<RankingViewModel, RankingState, RankingPresentationKey>((ref, key) {
  return RankingViewModel(key.ports.reader, key.scope);
});
