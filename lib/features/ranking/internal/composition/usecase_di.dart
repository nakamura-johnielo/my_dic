//================usecase=================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/ranking/internal/application/usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/features/ranking/internal/application/usecase/load_rankings/load_rankings_interactor.dart';
import 'package:my_dic/features/ranking/internal/application/usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/features/ranking/internal/application/usecase/update_ranking_filter/update_ranking_filter_interactor.dart';
import 'package:my_dic/features/ranking/internal/composition/data_di.dart';

final loadRankingsUseCaseProvider = Provider<ILoadRankingsUseCase>((ref) {
  return LoadRankingsInteractor(ref.read(rankingQueryRepositoryProvider));
});

final updateRankingFilterUseCaseProvider =
    Provider<IUpdateRankingFilterUseCase>((ref) {
  return UpdateRankingFilterInteractor();
});
