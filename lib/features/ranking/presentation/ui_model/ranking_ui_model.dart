import 'package:flutter/foundation.dart';
import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/core/common/enums/word/part_of_speech.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';

@immutable
class RankingState {
  final List<Ranking> items;
  final List<int> currentPageRange; // [min,max]
  final bool isLoadingNext;
  final bool isLoadingPrev;
  final bool hasNext;

  // filters (0: none, 1: include, -1: exclude)
  final Map<FeatureTag, int> featureTagFilters;
  final Map<PartOfSpeech, int> partOfSpeechFilters;
  final int pagenationFilter;

  const RankingState({
    this.items = const [],
    this.currentPageRange = const [-1, -1],
    this.isLoadingNext = false,
    this.isLoadingPrev = false,
    this.hasNext = true,
    this.featureTagFilters = const {},
    this.partOfSpeechFilters = const {},
    this.pagenationFilter = 0,
  });

  RankingState copyWith({
    List<Ranking>? items,
    List<int>? currentPageRange,
    bool? isLoadingNext,
    bool? isLoadingPrev,
    bool? hasNext,
    Map<FeatureTag, int>? featureTagFilters,
    Map<PartOfSpeech, int>? partOfSpeechFilters,
    int? paginationFilter,
  }) {
    return RankingState(
      items: items ?? this.items,
      currentPageRange: currentPageRange ?? this.currentPageRange,
      isLoadingNext: isLoadingNext ?? this.isLoadingNext,
      isLoadingPrev: isLoadingPrev ?? this.isLoadingPrev,
      hasNext: hasNext ?? this.hasNext,
      featureTagFilters: featureTagFilters ?? this.featureTagFilters,
      partOfSpeechFilters: partOfSpeechFilters ?? this.partOfSpeechFilters,
      pagenationFilter: paginationFilter ?? this.pagenationFilter,
    );
  }
}