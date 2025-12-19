import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/ranking/presentation/view_model/ranking_controller.dart';
import 'package:my_dic/features/ranking/presentation/view_model/ranking_view_model.dart';
import 'package:my_dic/features/ranking/di/usecase_di.dart';

import 'package:my_dic/features/ranking/presentation/presenter/load_rankings_presenter_impl.dart';
import 'package:my_dic/features/ranking/presentation/presenter/locate_ranking_pagenation_presenter_impl.dart';
import 'package:my_dic/features/ranking/presentation/presenter/update_ranking_filter_presenter_impl.dart';
import 'package:my_dic/features/ranking/presentation/presenter/update_status_presenter_impl.dart';


final rankingControllerProvider = Provider<RankingController>((ref) {
  return RankingController(
    ref.read(rankingViewModelProvider),
    ref.read(loadRankingsUseCaseProvider),
    ref.read(updateRankingFilterUseCaseProvider),
    ref.read(locateRankingPagenationUseCaseProvider),
    ref.read(updateStatusUseCaseProvider),
  );
});

final rankingViewModelProvider =
    ChangeNotifierProvider<RankingViewModel>((ref) {
  return RankingViewModel();
});





//
//
//



//================= Presenter=================
final loadRankingsPresenterProvider = Provider((ref) {
  return LoadRankingsPresenterImpl(ref.read(rankingViewModelProvider));
});

final updateRankingFilterPresenterProvider = Provider((ref) {
  return UpdateRankingFilterPresenterImpl(ref.read(rankingViewModelProvider));
});

final locateRankingPagenationPresenterProvider = Provider((ref) {
  return LocateRankingPagenationPresenterImpl(
      ref.read(rankingViewModelProvider));
});

final updateStatusPresenterProvider = Provider((ref) {
  return UpdateStatusPresenterImpl(ref.read(rankingViewModelProvider));
});