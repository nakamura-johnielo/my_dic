import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/ranking/internal/presentation/ui_model/ranking_ui_model.dart';
import 'package:my_dic/features/ranking/internal/presentation/view_model/new_ranking_view_model.dart';
import 'package:my_dic/features/ranking/port/presentation_dependencies.dart';

final rankingViewModelProvider = StateNotifierProvider.autoDispose
    .family<RankingViewModel, RankingState, SessionScopeKey>((ref, scope) {
  final dependencies = ref.watch(rankingPresentationDependenciesProvider);
  return RankingViewModel(dependencies.ports.reader, scope);
});
