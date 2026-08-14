import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/ranking/internal/presentation/ui_model/ranking_ui_model.dart';
import 'package:my_dic/features/ranking/internal/presentation/view_model/new_ranking_view_model.dart';
import 'package:my_dic/features/ranking/port/composition_contract.dart';

/// Internal presentation identity. Ports are compared by identity so a fake
/// capability can never share state with the runtime capability.
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
