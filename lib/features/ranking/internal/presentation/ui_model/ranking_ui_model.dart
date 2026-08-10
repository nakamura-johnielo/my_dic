import 'package:flutter/foundation.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';
import 'package:my_dic/features/ranking/port/model/ranking_list_item.dart';

/// The read payload for the ranking screen. Filters and page selection live in
/// [RankingState], so a query transition never discards the user's selection.
@immutable
class RankingResults {
  const RankingResults(this.items);

  final List<RankingListItem> items;

  /// A word may have multiple ranking rows; `rankingId` is the stable row key.
  RankingResults append(Iterable<RankingListItem> next) {
    final ids = items.map((item) => item.rankingId).toSet();
    return RankingResults([
      ...items,
      for (final item in next)
        if (ids.add(item.rankingId)) item,
    ]);
  }
}

@immutable
class RankingState {
  const RankingState({
    this.rankings = const QueryState.initial(),
    this.currentPage = -1,
    this.hasNext = true,
    this.featureTagFilters = const {},
    this.partOfSpeechFilters = const {},
    this.pagenationFilter = 0,
  });

  final QueryState<RankingResults> rankings;

  /// The last successfully loaded, zero-based page. `-1` means no page has
  /// completed loading for the current filters yet.
  final int currentPage;
  final bool hasNext;
  final Map<FeatureTag, int> featureTagFilters;
  final Map<CatalogPartOfSpeech, int> partOfSpeechFilters;
  final int pagenationFilter;

  /// Compatibility accessor for cards and pagination callers.
  List<RankingListItem> get items => rankings.dataOrNull?.items ?? const [];

  RankingState copyWith({
    QueryState<RankingResults>? rankings,
    int? currentPage,
    bool? hasNext,
    Map<FeatureTag, int>? featureTagFilters,
    Map<CatalogPartOfSpeech, int>? partOfSpeechFilters,
    int? paginationFilter,
  }) =>
      RankingState(
        rankings: rankings ?? this.rankings,
        currentPage: currentPage ?? this.currentPage,
        hasNext: hasNext ?? this.hasNext,
        // Keeping the existing maps is important for state-only updates. It
        // prevents observers from treating a loading/data transition as a
        // filter update merely because the map identity changed.
        featureTagFilters: featureTagFilters == null
            ? this.featureTagFilters
            : Map.unmodifiable(featureTagFilters),
        partOfSpeechFilters: partOfSpeechFilters == null
            ? this.partOfSpeechFilters
            : Map.unmodifiable(partOfSpeechFilters),
        pagenationFilter: paginationFilter ?? pagenationFilter,
      );
}
