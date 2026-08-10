import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/internal/application/usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/features/ranking/internal/application/usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/features/ranking/internal/presentation/ui_model/ranking_ui_model.dart';
import 'package:my_dic/features/ranking/port/model/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/port/model/update_ranking_filter_input_data.dart';
import 'package:logging/logging.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/session/session_scope_key.dart';

class RankingViewModel extends StateNotifier<RankingState> {
  RankingViewModel(
      this._loadRankingsUseCase, this._updateRankingFilterUseCase, this._scope)
      : super(const RankingState());

  final ILoadRankingsUseCase _loadRankingsUseCase;
  final IUpdateRankingFilterUseCase _updateRankingFilterUseCase;
  final SessionScopeKey _scope;
  final _logger = Logger('RankingViewModelV2');

  static const int _pageSize = 100;

  Future<bool> retry() => loadNextPage(state.currentPage + 1);

  Future<bool> loadNextPage(int page) async {
    AppLogger.print("loadnext on VM, page: $page");

    final previous = state.rankings.dataOrNull;
    state = state.copyWith(
      rankings: QueryState.loading(previousData: previous),
    );
    try {
      const pageSize = _pageSize;
      final input = LoadRankingsInputData(
        state.partOfSpeechFilters,
        state.featureTagFilters,
        page,
        pageSize,
        _scope.accountScope,
      );

      final result = await _loadRankingsUseCase.execute(input);

      return result.when(
        success: (output) {
          AppLogger.print(
              "==================- ranking items: ${output.items.length}");

          final value =
              (previous ?? const RankingResults([])).append(output.items);
          state = state.copyWith(
            rankings: value.items.isEmpty
                ? QueryState.empty()
                : QueryState.data(value),
            currentPage: page,
            hasNext: output.hasNext,
          );

          return output.hasNext;
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

  void addExcludeFilter(Object data) {
    //page=[-1,-1];をセット
    final input = UpdateRankingFilterInputData(data, -1);
    _updateFilter(input);
  }

  void addFilter(Object data) {
    //page=[-1,-1];をセット
    final input = UpdateRankingFilterInputData(data, 1);
    _updateFilter(input);
  }

  void removeFilter(Object data) {
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
    final data = res.data;
    int value = res.value;

    //filtertype: 0: delete, 1: add, -1: exclude
    RankingState? newState;
    if (data is CatalogPartOfSpeech) {
      newState = _updatePartOfSpeechFilter(data, value);
    } else if (data is FeatureTag) {
      newState = _updateFeatureTagFilter(data, value);
    }
    _resetPage(newState, resetPaginationFilter: true);
  }

  RankingState _updatePartOfSpeechFilter(
      CatalogPartOfSpeech filter, int value) {
    final newData =
        Map<CatalogPartOfSpeech, int>.from(state.partOfSpeechFilters)
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

  void _resetPage(RankingState? currentState,
      {bool resetPaginationFilter = false}) {
    if (currentState == null) {
      state = state.copyWith(
        currentPage: -1,
        paginationFilter: resetPaginationFilter ? 0 : null,
        rankings: const QueryState.initial(),
      );
      return;
    }
    state = currentState.copyWith(
      currentPage: -1,
      paginationFilter: resetPaginationFilter ? 0 : null,
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

  void setPartOfSpeechFilter(CatalogPartOfSpeech pos, int value) {
    _updateFilter(UpdateRankingFilterInputData(pos, value));
  }
}
