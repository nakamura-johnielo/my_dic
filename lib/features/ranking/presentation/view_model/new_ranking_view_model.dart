import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/enums/i_enum.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/domain/usecase/locate_ranking_pagenation/i_locate_ranking_pagenation_use_case.dart';
import 'package:my_dic/features/ranking/domain/usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/features/ranking/domain/usecase/update_ranking_filter/update_ranking_filter_input_data.dart';
import 'package:my_dic/features/ranking/presentation/ui_model/ranking_ui_model.dart';
import 'package:logging/logging.dart';

class RankingViewModelV2 extends StateNotifier<RankingState> {
  RankingViewModelV2(this._loadRankingsUseCase,
      this._locateRankingPagenationUseCase, this._updateRankingFilterUseCase)
      : super(const RankingState());

  final ILoadRankingsUseCase _loadRankingsUseCase;
  final ILocateRankingPagenationUseCase _locateRankingPagenationUseCase;
  final IUpdateRankingFilterUseCase _updateRankingFilterUseCase;
  final _logger = Logger('RankingViewModelV2');

  static const int _pageSize = 100;

  //TODO currentPage List<int> -> int
  Future<bool> loadNextPage(int nextPage) async {
    //print("loadnext");
    //if (state.isLoadingNext || !state.hasNext) return state.hasNext;

    //state = state.copyWith(isLoadingNext: true);
    print("loadnext on VM, pageRange: ${state.currentPageRange}");
    print("loadnext on VM, nextpage: $nextPage");

    try {
      final input = LoadRankingsInputData(
          state.partOfSpeechFilters,
          state.featureTagFilters,
          [state.currentPageRange[0], nextPage - 1],
          _pageSize,
          true,
          //TODO pagenationFilter
          state.pagenationFilter

          //nextPage - 1, // InfinityScroll仕様に合わせる（現行と同じ補正）
          );

      final result = await _loadRankingsUseCase.execute(input);

      return result.when(
        success: (output) {
          print("==================- ranking items: ${output.length}");
          final appended = [...state.items, ...output];
          final hasNext = output.length > _pageSize;

          state = state.copyWith(
            items: appended,
            currentPageRange: [state.currentPageRange[0], nextPage],
            hasNext: hasNext,
            isLoadingNext: false,
          );

          return hasNext;
        },
        failure: (error) {
          print("==================- ranking items:FAILURE");
          _logger.warning('ランキングの読み込みに失敗しました', error);
          state = state.copyWith(isLoadingNext: false);
          return false;
        },
      );
    } catch (_) {
      state = state.copyWith(isLoadingNext: false);
      rethrow;
    }
  }

  void setPageRange(List<int> pageRange) {
    state = state.copyWith(currentPageRange: pageRange);
  }

  void setNextPage(int nextPage) {
    state =
        state.copyWith(currentPageRange: [state.currentPageRange[0], nextPage]);
  }

  void addExcludeFilter(DisplayEnumMixin data) {
    //page=[-1,-1];をセット
    final input = UpdateRankingFilterInputData(data, -1);
    _updateFilter(input);
  }

  void addFilter(DisplayEnumMixin data) {
    //page=[-1,-1];をセット
    final input = UpdateRankingFilterInputData(data, 1);
    _updateFilter(input);
  }

  void removeFilter(DisplayEnumMixin data) {
    //page=[-1,-1];をセット
    final input = UpdateRankingFilterInputData(data, 0);
    _updateFilter(input);
  }

  void locatePage(int page) {
    //pagenationのページ番号
    _resetPage(state.copyWith(paginationFilter: page));
  }

  ///==========private method==================================

  void _updateFilter(UpdateRankingFilterInputData input) {
    final res = _updateRankingFilterUseCase.execute(input);
    DisplayEnumMixin data = res.data;
    int value = res.value;

    //filtertype: 0: delete, 1: add, -1: exclude
    RankingState? newState;
    if (data is PartOfSpeech) {
      newState = _updatePartOfSpeechFilter(data, value);
    } else if (data is FeatureTag) {
      newState = _updateFeatureTagFilter(data, value);
    }
    _resetPage(newState);
    //loadNextPage(0);
  }

  RankingState _updatePartOfSpeechFilter(PartOfSpeech filter, int value) {
    final newData = Map<PartOfSpeech, int>.from(state.partOfSpeechFilters)
      ..[filter] = value;
    print('updated POS filter: $newData');
    return state.copyWith(
      partOfSpeechFilters: newData,
      hasNext: true,
    );
  }

  RankingState _updateFeatureTagFilter(FeatureTag filter, int value) {
    final newData = Map<FeatureTag, int>.from(state.featureTagFilters)
      ..[filter] = value;

    return state.copyWith(
      featureTagFilters: newData,
      hasNext: true,
    );
  }

  void _resetPage(RankingState? currentState) {
    //log("updatefilter in presenter");
    if (currentState == null) {
      state = state.copyWith(currentPageRange: [-1, -1], items: []);
      return;
    }
    state = currentState.copyWith(currentPageRange: [-1, -1], items: []);
    //_rankingViewModel.checkUpdateFilter();
  }

  ///============================================
  void resetAndReload({int initialPage = 0}) {
    state = const RankingState();
    // UI側で InfinityScrollController.reset() を呼び、必要なら loadNextPage(initialPage) を叩く
  }

  void setFeatureTagFilter(FeatureTag tag, int value) {
    final next = Map<FeatureTag, int>.from(state.featureTagFilters)
      ..[tag] = value;
    state = state.copyWith(featureTagFilters: next, hasNext: true);
  }

  void setPartOfSpeechFilter(PartOfSpeech pos, int value) {
    final next = Map<PartOfSpeech, int>.from(state.partOfSpeechFilters)
      ..[pos] = value;
    state = state.copyWith(partOfSpeechFilters: next, hasNext: true);
  }
}
