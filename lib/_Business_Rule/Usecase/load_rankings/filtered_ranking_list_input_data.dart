import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';

class FilteredRankingListInputData {
  int requiredPage;
  int size;
  Set<PartOfSpeech> partOfSpeechFilters;
  Set<FeatureTag> featureTagFilters;

  FilteredRankingListInputData(this.partOfSpeechFilters, this.featureTagFilters,
      this.requiredPage, this.size);
}
