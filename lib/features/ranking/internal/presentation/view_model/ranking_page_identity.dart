import 'package:flutter/foundation.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';

@immutable
final class RankingNormalizedFilter {
  RankingNormalizedFilter({
    Map<CatalogPartOfSpeech, int> partOfSpeech = const {},
    Map<FeatureTag, int> featureTags = const {},
  })  : partOfSpeech = Map.unmodifiable(_withoutNeutral(partOfSpeech)),
        featureTags = Map.unmodifiable(_withoutNeutral(featureTags));

  final Map<CatalogPartOfSpeech, int> partOfSpeech;
  final Map<FeatureTag, int> featureTags;

  static Map<T, int> _withoutNeutral<T>(Map<T, int> source) => {
        for (final entry in source.entries)
          if (entry.value != 0) entry.key: entry.value,
      };

  @override
  bool operator ==(Object other) =>
      other is RankingNormalizedFilter &&
      mapEquals(partOfSpeech, other.partOfSpeech) &&
      mapEquals(featureTags, other.featureTags);

  @override
  int get hashCode => Object.hash(
        Object.hashAllUnordered(
          partOfSpeech.entries
              .map((entry) => Object.hash(entry.key, entry.value)),
        ),
        Object.hashAllUnordered(
          featureTags.entries
              .map((entry) => Object.hash(entry.key, entry.value)),
        ),
      );
}

@immutable
final class RankingPageIdentity {
  const RankingPageIdentity({
    required this.sessionKey,
    required this.normalizedFilter,
    required this.page,
    required this.size,
  });

  final SessionScopeKey sessionKey;
  final RankingNormalizedFilter normalizedFilter;
  final int page;
  final int size;

  @override
  bool operator ==(Object other) =>
      other is RankingPageIdentity &&
      other.sessionKey == sessionKey &&
      other.normalizedFilter == normalizedFilter &&
      other.page == page &&
      other.size == size;

  @override
  int get hashCode => Object.hash(sessionKey, normalizedFilter, page, size);
}

@immutable
final class RankingRequestToken {
  const RankingRequestToken({
    required this.generation,
    required this.pageIdentity,
    required this.attempt,
  });

  final int generation;
  final RankingPageIdentity pageIdentity;
  final int attempt;

  @override
  bool operator ==(Object other) =>
      other is RankingRequestToken &&
      other.generation == generation &&
      other.pageIdentity == pageIdentity &&
      other.attempt == attempt;

  @override
  int get hashCode => Object.hash(generation, pageIdentity, attempt);
}
