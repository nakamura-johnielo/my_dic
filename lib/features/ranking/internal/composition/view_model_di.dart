import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/ranking/internal/composition/usecase_di.dart';
import 'package:my_dic/features/ranking/internal/presentation/ui_model/ranking_ui_model.dart';
import 'package:my_dic/features/ranking/internal/presentation/view_model/new_ranking_view_model.dart';
import 'package:my_dic/core/session/session_scope_key.dart';

final rankingViewModelProvider = StateNotifierProvider.autoDispose
    .family<RankingViewModel, RankingState, SessionScopeKey>((ref, scope) {
  return RankingViewModel(ref.read(loadRankingsUseCaseProvider),
      ref.read(updateRankingFilterUseCaseProvider), scope);
});
