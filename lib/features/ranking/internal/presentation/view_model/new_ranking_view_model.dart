import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';
import 'package:my_dic/features/ranking/internal/application/usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/features/ranking/internal/application/usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/features/ranking/internal/presentation/ui_model/ranking_ui_model.dart';
import 'package:my_dic/features/ranking/internal/presentation/view_model/ranking_page_identity.dart';
import 'package:my_dic/features/ranking/port/model/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/port/model/update_ranking_filter_input_data.dart';

class RankingViewModel extends StateNotifier<RankingState> {
  RankingViewModel(
    this._loadRankingsUseCase,
    this._updateRankingFilterUseCase,
    this._scope,
  ) : super(const RankingState());

  final ILoadRankingsUseCase _loadRankingsUseCase;
  final IUpdateRankingFilterUseCase _updateRankingFilterUseCase;
  final SessionScopeKey _scope;
  final _logger = Logger('RankingViewModelV2');

  static const int _pageSize = 100;
  int _generation = 0;
  int _attempt = 0;
  RankingRequestToken? _activeRequest;
  RankingPageIdentity? _failedPage;

  /// Retry is owned by the VM because the controller has no business identity.
  Future<bool> retry() {
    final failedPage = _failedPage;
    if (failedPage == null) return Future.value(false);
    return _load(failedPage);
  }

  Future<bool> loadNextPage(int page) => _load(_identityFor(page));

  Future<bool> _load(RankingPageIdentity identity) async {
    if (!mounted || identity.sessionKey != _scope) return false;
    if (identity.page > 0 && !state.hasNext) return false;
    if (_activeRequest?.pageIdentity == identity) return false;

    final token = RankingRequestToken(
      generation: _generation,
      pageIdentity: identity,
      attempt: ++_attempt,
    );
    _activeRequest = token;
    final previous = state.rankings.dataOrNull;
    state =
        state.copyWith(rankings: QueryState.loading(previousData: previous));

    try {
      final result = await _loadRankingsUseCase.execute(LoadRankingsInputData(
        identity.normalizedFilter.partOfSpeech,
        identity.normalizedFilter.featureTags,
        identity.page,
        identity.size,
        _scope.accountScope,
      ));
      if (!_isCurrent(token)) return false;

      return result.when(
        success: (output) {
          final current = state.rankings.dataOrNull;
          final results = identity.page == 0
              ? RankingResults(output.items)
              : (current ?? const RankingResults([])).append(output.items);
          state = state.copyWith(
            rankings: results.items.isEmpty
                ? QueryState.empty()
                : QueryState.data(results),
            currentPage: identity.page,
            hasNext: output.hasNext,
          );
          _failedPage = null;
          _clearActive(token);
          return output.hasNext;
        },
        failure: (error) {
          _logger.warning('Failed to load ranking page.', error);
          state = state.copyWith(
            rankings: QueryState.failure(
              error,
              previousData: state.rankings.dataOrNull ?? previous,
            ),
          );
          _failedPage = identity;
          _clearActive(token);
          return false;
        },
      );
    } catch (error) {
      if (!_isCurrent(token)) return false;
      state = state.copyWith(
        rankings: QueryState.failure(
          UnexpectedError(message: error.toString()),
          previousData: state.rankings.dataOrNull ?? previous,
        ),
      );
      _failedPage = identity;
      _clearActive(token);
      return false;
    }
  }

  void addExcludeFilter(Object data) =>
      _updateFilter(UpdateRankingFilterInputData(data, -1));

  void addFilter(Object data) =>
      _updateFilter(UpdateRankingFilterInputData(data, 1));

  void removeFilter(Object data) =>
      _updateFilter(UpdateRankingFilterInputData(data, 0));

  void locatePage(int page) =>
      _resetPage(state.copyWith(paginationFilter: page));

  void _updateFilter(UpdateRankingFilterInputData input) {
    final result = _updateRankingFilterUseCase.execute(input);
    final data = result.data;
    final value = result.value;
    RankingState? next;
    if (data is CatalogPartOfSpeech) {
      next = state.copyWith(
        partOfSpeechFilters: Map<CatalogPartOfSpeech, int>.from(
          state.partOfSpeechFilters,
        )..[data] = value,
        hasNext: true,
      );
    } else if (data is FeatureTag) {
      next = state.copyWith(
        featureTagFilters: Map<FeatureTag, int>.from(state.featureTagFilters)
          ..[data] = value,
        hasNext: true,
      );
    }
    _resetPage(next, resetPaginationFilter: true);
  }

  void _resetPage(RankingState? currentState,
      {bool resetPaginationFilter = false}) {
    _invalidateRequests();
    final source = currentState ?? state;
    state = source.copyWith(
      currentPage: -1,
      hasNext: true,
      paginationFilter: resetPaginationFilter ? 0 : null,
      rankings: const QueryState.initial(),
    );
  }

  void resetAndReload({int initialPage = 0}) {
    _invalidateRequests();
    state = const RankingState();
  }

  void setFeatureTagFilter(FeatureTag tag, int value) =>
      _updateFilter(UpdateRankingFilterInputData(tag, value));

  void setPartOfSpeechFilter(CatalogPartOfSpeech pos, int value) =>
      _updateFilter(UpdateRankingFilterInputData(pos, value));

  RankingPageIdentity _identityFor(int page) => RankingPageIdentity(
        sessionKey: _scope,
        normalizedFilter: RankingNormalizedFilter(
          partOfSpeech: state.partOfSpeechFilters,
          featureTags: state.featureTagFilters,
        ),
        page: page,
        size: _pageSize,
      );

  bool _isCurrent(RankingRequestToken token) =>
      mounted && _generation == token.generation && _activeRequest == token;

  void _clearActive(RankingRequestToken token) {
    if (_activeRequest == token) _activeRequest = null;
  }

  void _invalidateRequests() {
    _generation++;
    _activeRequest = null;
    _failedPage = null;
  }

  @override
  void dispose() {
    _invalidateRequests();
    super.dispose();
  }
}
