import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/features/ranking/internal/domain/ranking_filter_selection.dart';
import 'package:my_dic/features/ranking/internal/presentation/ui_model/ranking_ui_model.dart';
import 'package:my_dic/features/ranking/internal/presentation/view_model/ranking_page_identity.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';

final class RankingViewModel extends StateNotifier<RankingState> {
  RankingViewModel(this._reader, this._scope) : super(RankingState());

  final RankingPageReaderPort _reader;
  final SessionScopeKey _scope;
  final _logger = Logger('RankingViewModel');

  static const int _pageSize = 100;
  int _generation = 0;
  int _attempt = 0;
  RankingRequestToken? _activeRequest;
  RankingPageIdentity? _failedPage;

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
    state = state.copyWith(
      rankings: QueryState.loading(previousData: previous),
    );

    try {
      final result = await _reader.readPage(
        RankingPageQuery(
          page: identity.page,
          size: identity.size,
          scope: _rankingScope(identity.sessionKey),
          filter: identity.filter,
        ),
      );
      if (!_isCurrent(token)) return false;

      if (result case Success<RankingPage>(data: final output)) {
        final current = state.rankings.dataOrNull;
        final results = identity.page == 0
            ? RankingResults(output.items)
            : (current ?? RankingResults(const [])).append(output.items);
        state = state.copyWith(
          rankings: results.items.isEmpty
              ? QueryState.empty()
              : QueryState.data(results),
          currentPage: identity.page,
          hasNext: output.hasMore,
        );
        _failedPage = null;
        _clearActive(token);
        return output.hasMore;
      }
      final error = result.errorOrNull!;
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

  void setPartOfSpeechFilter(
    RankingPartOfSpeech value,
    RankingFilterSelection selection,
  ) {
    final included = {...state.filter.includedPartsOfSpeech}..remove(value);
    final excluded = {...state.filter.excludedPartsOfSpeech}..remove(value);
    switch (selection) {
      case RankingFilterSelection.neutral:
        break;
      case RankingFilterSelection.include:
        included.add(value);
      case RankingFilterSelection.exclude:
        excluded.add(value);
    }
    _replaceFilter(RankingFilter(
      includedPartsOfSpeech: included,
      excludedPartsOfSpeech: excluded,
      includedStatuses: state.filter.includedStatuses,
      excludedStatuses: state.filter.excludedStatuses,
      groupByCatalogWord: state.filter.groupByCatalogWord,
    ));
  }

  void setStatusFilter(
    RankingStatusFilter value,
    RankingFilterSelection selection,
  ) {
    final included = {...state.filter.includedStatuses}..remove(value);
    final excluded = {...state.filter.excludedStatuses}..remove(value);
    switch (selection) {
      case RankingFilterSelection.neutral:
        break;
      case RankingFilterSelection.include:
        included.add(value);
      case RankingFilterSelection.exclude:
        excluded.add(value);
    }
    _replaceFilter(RankingFilter(
      includedPartsOfSpeech: state.filter.includedPartsOfSpeech,
      excludedPartsOfSpeech: state.filter.excludedPartsOfSpeech,
      includedStatuses: included,
      excludedStatuses: excluded,
      groupByCatalogWord: state.filter.groupByCatalogWord,
    ));
  }

  void setGroupByCatalogWord(bool selected) => _replaceFilter(RankingFilter(
        includedPartsOfSpeech: state.filter.includedPartsOfSpeech,
        excludedPartsOfSpeech: state.filter.excludedPartsOfSpeech,
        includedStatuses: state.filter.includedStatuses,
        excludedStatuses: state.filter.excludedStatuses,
        groupByCatalogWord: selected,
      ));

  void locatePage(int page) => _resetPage(
        state.copyWith(paginationFilter: page),
      );

  void _replaceFilter(RankingFilter filter) => _resetPage(
        state.copyWith(filter: filter, hasNext: true),
        resetPaginationFilter: true,
      );

  void _resetPage(
    RankingState currentState, {
    bool resetPaginationFilter = false,
  }) {
    _invalidateRequests();
    state = currentState.copyWith(
      currentPage: -1,
      hasNext: true,
      paginationFilter: resetPaginationFilter ? 0 : null,
      rankings: const QueryState.initial(),
    );
  }

  void resetAndReload() {
    _invalidateRequests();
    state = RankingState();
  }

  RankingPageIdentity _identityFor(int page) => RankingPageIdentity(
        sessionKey: _scope,
        filter: state.filter,
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

RankingAccountScope _rankingScope(SessionScopeKey scope) =>
    scope.accountScope == guestAccountScope
        ? const RankingAccountScope.guest()
        : RankingAccountScope.account(scope.accountScope);
