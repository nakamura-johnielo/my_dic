import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/ranking/presentation/ui_model/ranking_ui_model.dart';
import 'package:my_dic/features/ranking/presentation/view_model/new_ranking_view_model.dart';
import 'package:my_dic/features/ranking/presentation/view_model/ranking_view_model.dart';
import 'package:my_dic/features/ranking/di/usecase_di.dart';
import 'package:my_dic/features/ranking/presentation/presenter/update_status_presenter_impl.dart';


// final rankingControllerProvider = Provider<RankingController>((ref) {
//   return RankingController(
//     ref.read(rankingViewModelProvider),
//     ref.read(loadRankingsUseCaseProvider),
//     ref.read(updateRankingFilterUseCaseProvider),
//     ref.read(locateRankingPagenationUseCaseProvider),
//     ref.read(updateStatusUseCaseProvider),
//   );s
// });

final rankingViewModelProviderLegacy =
    ChangeNotifierProvider<RankingViewModel>((ref) {
  return RankingViewModel();
});


final rankingViewModelProvider =
    StateNotifierProvider<RankingViewModelV2, RankingState>((ref) {
  return RankingViewModelV2(
    ref.read(loadRankingsUseCaseProvider),
    ref.read(locateRankingPagenationUseCaseProvider),
    ref.read(updateRankingFilterUseCaseProvider),
  );
});





//
//
//



//================= Presenter=================
// final loadRankingsPresenterProvider = Provider((ref) {
//   return LoadRankingsPresenterImpl(ref.read(rankingViewModelProvider));
// });

// final updateRankingFilterPresenterProvider = Provider((ref) {
//   return UpdateRankingFilterPresenterImpl(ref.read(rankingViewModelProvider));
// });

// final locateRankingPagenationPresenterProvider = Provider((ref) {
//   return LocateRankingPagenationPresenterImpl(
//       ref.read(rankingViewModelProvider));
// });

final updateStatusPresenterProvider = Provider((ref) {
  return UpdateStatusPresenterImpl(ref.read(rankingViewModelProviderLegacy));
});