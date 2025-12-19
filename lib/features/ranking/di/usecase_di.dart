
//================usecase=================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/load_rankings_interactor.dart';
import 'package:my_dic/features/ranking/domain/usecase/locate_ranking_pagenation/i_locate_ranking_pagenation_use_case.dart';
import 'package:my_dic/features/ranking/domain/usecase/locate_ranking_pagenation/locate_ranking_pagenation_interactor.dart';
import 'package:my_dic/features/ranking/domain/usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/features/ranking/domain/usecase/update_ranking_filter/update_ranking_filter_interactor.dart';
import 'package:my_dic/core/di/data/repository_di.dart';
import 'package:my_dic/core/domain/usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_interactor.dart';
import 'package:my_dic/features/ranking/di/view_model_di.dart';

final updateStatusUseCaseProvider = Provider<IUpdateStatusUseCase>((ref) {
  return UpdateStatusInteractor(
    ref.read(updateStatusPresenterProvider),
    ref.read(esjWordRepositoryProvider),
  );
});

final loadRankingsUseCaseProvider = Provider<ILoadRankingsUseCase>((ref) {
  return LoadRankingsInteractor(
    ref.read(loadRankingsPresenterProvider),
    ref.read(espRankingRepositoryProvider),
  );
});

final updateRankingFilterUseCaseProvider =
    Provider<IUpdateRankingFilterUseCase>((ref) {
  return UpdateRankingFilterInteractor(
      ref.read(updateRankingFilterPresenterProvider));
});

final locateRankingPagenationUseCaseProvider =
    Provider<ILocateRankingPagenationUseCase>((ref) {
  return LocateRankingPagenationInteractor(
      ref.read(locateRankingPagenationPresenterProvider));
});
