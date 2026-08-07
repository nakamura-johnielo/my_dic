import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';

/// Immutable input for one account-scoped ranking page query.
class RankingQuery {
  RankingQuery({
    required this.page,
    required this.size,
    required this.accountId,
    Set<PartOfSpeech> includedPartOfSpeech = const {},
    Set<PartOfSpeech> excludedPartOfSpeech = const {},
    Set<FeatureTag> includedFeatureTags = const {},
    Set<FeatureTag> excludedFeatureTags = const {},
  })  : includedPartOfSpeech = Set.unmodifiable(includedPartOfSpeech),
        excludedPartOfSpeech = Set.unmodifiable(excludedPartOfSpeech),
        includedFeatureTags = Set.unmodifiable(includedFeatureTags),
        excludedFeatureTags = Set.unmodifiable(excludedFeatureTags) {
    if (page < 0) {
      throw ArgumentError.value(page, 'page', 'must be zero or greater');
    }
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'must be greater than zero');
    }
    if (accountId.isEmpty) {
      throw ArgumentError.value(accountId, 'accountId', 'must not be empty');
    }
  }

  /// Zero-based page index.
  final int page;
  final int size;
  final String accountId;
  final Set<PartOfSpeech> includedPartOfSpeech;
  final Set<PartOfSpeech> excludedPartOfSpeech;
  final Set<FeatureTag> includedFeatureTags;
  final Set<FeatureTag> excludedFeatureTags;
}
