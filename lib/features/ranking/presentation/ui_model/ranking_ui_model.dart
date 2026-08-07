import 'package:flutter/foundation.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';

/// The read payload for the ranking screen. Filters and page selection live in
/// [RankingState], so a query transition never discards the user's selection.
@immutable
class RankingResults {
  const RankingResults(this.items);

  final List<Ranking> items;

  RankingResults append(Iterable<Ranking> next) =>
      RankingResults([...items, ...next]);
}

@immutable
class RankingState {
  const RankingState({
    this.rankings = const QueryState.initial(),
    this.currentPageRange = const [-1, -1],
    this.hasNext = true,
    this.featureTagFilters = const {},
    this.partOfSpeechFilters = const {},
    this.pagenationFilter = 0,
  });

  final QueryState<RankingResults> rankings;
  final List<int> currentPageRange; // [min,max]
  final bool hasNext;
  final Map<FeatureTag, int> featureTagFilters;
  final Map<PartOfSpeech, int> partOfSpeechFilters;
  final int pagenationFilter;

  /// Compatibility accessor for cards and pagination callers.
  List<Ranking> get items => rankings.dataOrNull?.items ?? const [];

  RankingState copyWith({
    QueryState<RankingResults>? rankings,
    List<int>? currentPageRange,
    bool? hasNext,
    Map<FeatureTag, int>? featureTagFilters,
    Map<PartOfSpeech, int>? partOfSpeechFilters,
    int? paginationFilter,
  }) =>
      RankingState(
        rankings: rankings ?? this.rankings,
        currentPageRange: currentPageRange ?? this.currentPageRange,
        hasNext: hasNext ?? this.hasNext,
        featureTagFilters: featureTagFilters ?? this.featureTagFilters,
        partOfSpeechFilters: partOfSpeechFilters ?? this.partOfSpeechFilters,
        pagenationFilter: paginationFilter ?? pagenationFilter,
      );
}
