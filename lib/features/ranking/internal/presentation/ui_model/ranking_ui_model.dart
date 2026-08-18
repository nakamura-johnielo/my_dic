import 'package:flutter/foundation.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';

@immutable
final class RankingResults {
  RankingResults(Iterable<RankingItem> items) : items = List.unmodifiable(items);

  final List<RankingItem> items;

  RankingResults append(Iterable<RankingItem> next) {
    final ids = items.map((item) => item.id).toSet();
    return RankingResults([
      ...items,
      for (final item in next)
        if (ids.add(item.id)) item,
    ]);
  }
}

@immutable
final class RankingState {
  RankingState({
    this.rankings = const QueryState.initial(),
    this.currentPage = -1,
    this.hasNext = true,
    RankingFilter? filter,
    this.pagenationFilter = 0,
  }) : filter = filter ?? RankingFilter();

  final QueryState<RankingResults> rankings;
  final int currentPage;
  final bool hasNext;
  final RankingFilter filter;
  final int pagenationFilter;

  List<RankingItem> get items => rankings.dataOrNull?.items ?? const [];

  RankingState copyWith({
    QueryState<RankingResults>? rankings,
    int? currentPage,
    bool? hasNext,
    RankingFilter? filter,
    int? paginationFilter,
  }) =>
      RankingState(
        rankings: rankings ?? this.rankings,
        currentPage: currentPage ?? this.currentPage,
        hasNext: hasNext ?? this.hasNext,
        filter: filter ?? this.filter,
        pagenationFilter: paginationFilter ?? pagenationFilter,
      );
}
