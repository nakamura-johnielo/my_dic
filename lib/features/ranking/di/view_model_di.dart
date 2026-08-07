import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/ranking/presentation/ui_model/ranking_ui_model.dart';
import 'package:my_dic/features/ranking/presentation/view_model/new_ranking_view_model.dart';
import 'package:my_dic/features/ranking/di/usecase_di.dart';

final rankingViewModelProvider =
    StateNotifierProvider<RankingViewModel, RankingState>((ref) {
  return RankingViewModel(ref.read(loadRankingsUseCaseProvider),
      ref.read(updateRankingFilterUseCaseProvider));
});
