import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';

class FilteredRankingListInputData {
  final int requiredPage;
  final int size;
  final Set<PartOfSpeech> partOfSpeechFilters;
  final Set<FeatureTag> featureTagFilters;
  final Set<PartOfSpeech> partOfSpeechExcludeFilters;
  final Set<FeatureTag> featureTagExcludeFilters;

  const FilteredRankingListInputData(
    this.partOfSpeechFilters,
    this.featureTagFilters,
    this.partOfSpeechExcludeFilters,
    this.featureTagExcludeFilters,
    this.requiredPage,
    this.size,
  );
}
