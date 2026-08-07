import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/enums/i_enum.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/features/ranking/application/usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/features/ranking/application/usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/application/usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/features/ranking/application/usecase/update_ranking_filter/update_ranking_filter_input_data.dart';
import 'package:my_dic/features/ranking/presentation/ui_model/ranking_ui_model.dart';
import 'package:logging/logging.dart';
import 'package:my_dic/app/routing/contracts/word_detail_route.dart';
import 'package:my_dic/router/navigator_service.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';

class RankingViewModel extends StateNotifier<RankingState> {
  RankingViewModel(this._loadRankingsUseCase, this._updateRankingFilterUseCase,
      this._naviService)
      : super(const RankingState());

  final ILoadRankingsUseCase _loadRankingsUseCase;
  final IUpdateRankingFilterUseCase _updateRankingFilterUseCase;
  final AppNavigatorService _naviService;
  final _logger = Logger('RankingViewModelV2');

  static const int _pageSize = 100;

  void goToQuiz(QuizGameRoute route) {
    _naviService.toFlashCard(route);
  }

  void goToDetail(WordDetailRoute route) {
    _naviService.toWordDetail(route);
  }

  Future<bool> retry() => loadNextPage(state.currentPageRange[1] + 1);

  //TODO currentPage List<int> -> int
  Future<bool> loadNextPage(int nextPage) async {
    AppLogger.print("loadnext on VM, pageRange: ${state.currentPageRange}");
    AppLogger.print("loadnext on VM, nextpage: $nextPage");

    final previous = state.rankings.dataOrNull;
    state = state.copyWith(
      rankings: QueryState.loading(previousData: previous),
    );
    try {
      const pageSize = _pageSize + 1;
      final input = LoadRankingsInputData(
          state.partOfSpeechFilters,
          state.featureTagFilters,
          [state.currentPageRange[0], nextPage - 1],
          pageSize,
          true,
          //TODO pagenationFilter
          state.pagenationFilter);

      final result = await _loadRankingsUseCase.execute(input);

      return result.when(
        success: (output) {
          AppLogger.print(
              "==================- ranking items: ${output.length}");
          final hasNext = output.length == pageSize;
          final visibleItems = hasNext ? output.take(_pageSize) : output;

          final value =
              (previous ?? const RankingResults([])).append(visibleItems);
          state = state.copyWith(
            rankings: value.items.isEmpty
                ? QueryState.empty()
                : QueryState.data(value),
            currentPageRange: [state.currentPageRange[0], nextPage],
            hasNext: hasNext,
          );

          return hasNext;
        },
        failure: (error) {
          AppLogger.print("==================- ranking items:FAILURE");
          _logger.warning('ランキングの読み込みに失敗しました', error);
          state = state.copyWith(
            rankings: QueryState.failure(error, previousData: previous),
          );
          return false;
        },
      );
    } catch (error) {
      state = state.copyWith(
        rankings: QueryState.failure(
          UnexpectedError(message: error.toString()),
          previousData: previous,
        ),
      );
      return false;
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
  }

  RankingState _updatePartOfSpeechFilter(PartOfSpeech filter, int value) {
    final newData = Map<PartOfSpeech, int>.from(state.partOfSpeechFilters)
      ..[filter] = value;
    AppLogger.print('updated POS filter: $newData');
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
    if (currentState == null) {
      state = state.copyWith(
        currentPageRange: [-1, -1],
        rankings: const QueryState.initial(),
      );
      return;
    }
    state = currentState.copyWith(
      currentPageRange: [-1, -1],
      rankings: const QueryState.initial(),
    );
  }

  ///============================================
  void resetAndReload({int initialPage = 0}) {
    state = const RankingState();
    // UI側で InfinityScrollController.reset() を呼び、必要なら loadNextPage(initialPage) を叩く
  }

  void setFeatureTagFilter(FeatureTag tag, int value) {
    _updateFilter(UpdateRankingFilterInputData(tag, value));
  }

  void setPartOfSpeechFilter(PartOfSpeech pos, int value) {
    _updateFilter(UpdateRankingFilterInputData(pos, value));
  }
}
