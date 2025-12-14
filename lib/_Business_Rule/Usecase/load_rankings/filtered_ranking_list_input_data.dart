import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/core/common/enums/word/part_of_speech.dart';

class FilteredRankingListInputData {
  int requiredPage;
  int size;
  Set<PartOfSpeech> partOfSpeechFilters;
  Set<FeatureTag> featureTagFilters;
  Set<PartOfSpeech> partOfSpeechExcludeFilters;
  Set<FeatureTag> featureTagExcludeFilters;

  FilteredRankingListInputData(
      this.partOfSpeechFilters,
      this.featureTagFilters,
      this.partOfSpeechExcludeFilters,
      this.featureTagExcludeFilters,
      this.requiredPage,
      this.size);
}
